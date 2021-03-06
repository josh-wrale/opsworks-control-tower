require 'thor'
require 'fog'
require 'zlib'
require 'archive/tar/minitar'

class Cookbooks < Thor
  include Archive::Tar
  include Thor::Actions

  desc 'install', 'Install cookbooks from Berksfile'
  def install
    run 'bundle exec berks install --path cookbooks'
  end

  desc 'upload ACCESS_KEY SECRET_ACCESS_KEY', 'Upload cookbooks to S3'
  option :environment, required: true
  option :install, type: :boolean, default: false
  def upload(access_key, secret_access_key)
    save_credentials(access_key, secret_access_key)

    environment = options[:environment]

    if options[:install]
      if !install
        raise Thor::Error, "Cookbook installation failed; aborting upload."
      end

      puts
    end

    puts "Uploading to S3"

    FileUtils.mkdir_p('tmp')
    cookbook_tarball_name = File.join('tmp', 'cookbooks.tgz')
    tgz = Zlib::GzipWriter.new(File.open(cookbook_tarball_name, 'wb'))

    package = YAML::load(ERB.new(File.read('package.yml')).result).freeze
    package.each {|c| puts "Packaging #{c}" }
    package = package.collect{|c| "cookbooks/#{c}"}

    Minitar.pack(package, tgz)

    remote_file = directory.files.head(cookbook_tarball_name)
    remote_file.destroy if remote_file

    directory.files.create(
      key: "#{environment}/cookbooks.tgz",
      body: File.open(cookbook_tarball_name)
    )
  end

  no_tasks do
    def save_credentials(access_key, secret_access_key)
      @access_key = access_key
      @secret_access_key = secret_access_key
    end

    def connection
      Fog::Storage.new({
        provider: 'AWS',
        aws_access_key_id: @access_key,
        aws_secret_access_key: @secret_access_key,
        region: 'us-east-1'
      })
    end

    def directory
      connection.directories.get('ace-opsworks-cookbooks')
    end
  end
end

require 'thor'
require 'fog'
require 'zlib'
require 'archive/tar/minitar'

class Cookbooks < Thor
  include Archive::Tar

  desc 'install', 'Install cookbooks from Berksfile'
  def install
    puts `./bin/berks install --path cookbooks`
  end

  desc 'upload ACCESS_KEY SECRET_ACCESS_KEY', 'Upload cookbooks to S3'
  option :environment, default: 'production'
  option :install, type: :boolean, default: false
  def upload(access_key, secret_access_key)
    save_credentials(access_key, secret_access_key)

    environment = options[:environment]

    if options[:install]
      install
      puts
    end

    puts "Uploading to S3"

    directory.files.each { |file| file.destroy }

    FileUtils.mkdir_p('tmp')
    cookbook_tarball_name = File.join('tmp', 'cookbooks.tgz')
    tgz = Zlib::GzipWriter.new(File.open(cookbook_tarball_name, 'wb'))
    Minitar.pack('cookbooks', tgz)

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
      directory = connection.directories.get('ace-opsworks-cookbooks')
    end
  end
end

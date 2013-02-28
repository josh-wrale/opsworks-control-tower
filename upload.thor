require 'thor'
require 'fog'
require 'zlib'
require 'archive/tar/minitar'

class Upload < Thor
  include Archive::Tar

  desc 'cookbooks ACCESS_KEY SECRET_ACCESS_KEY', 'Upload cookbooks to S3'
  option :environment
  def cookbooks(access_key, secret_access_key)
    save_credentials(access_key, secret_access_key)

    environment = options.fetch(:environment, 'production')

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

Upload.start

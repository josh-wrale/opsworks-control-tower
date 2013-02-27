require 'thor'
require 'fog'

class Upload < Thor
  desc 'cookbooks ACCESS_KEY SECRET_ACCESS_KEY', 'Upload cookbooks to S3'
  def cookbooks(access_key, secret_access_key)
    save_credentials(access_key, secret_access_key)

    directory.files.each { |file| file.destroy }

    Dir[File.join('cookbooks', '**', '**')].each do |file|
      next if File.directory?(file)
      puts file

      remote_file = directory.files.create(
        key: file.gsub(%r|^cookbooks/|, ''),
        body: File.open(file)
      )
    end
  end

  desc 'cookbook NAME ACCESS_KEY SECRET_ACCESS_KEY', 'Upload a single cookbook to S3'
  def cookbook(name, access_key, secret_access_key)
    save_credentials(access_key, secret_access_key)

    directory.files.all(prefix: "#{name}/").each do |file|
      file.destroy
    end

    Dir[File.join('cookbooks', name, '**', '**')].each do |file|
      next if File.directory?(file)
      puts file

      remote_file = directory.files.create(
        key: file.gsub(%r|^cookbooks/|, ''),
        body: File.open(file)
      )
    end
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

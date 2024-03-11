require 'fileutils'

module Utilities
  def create_file_with_contents(path, contents = '')
    ensure_directory(path)

    File.open(path, 'w') do |f|
      f.write(contents)
    end
  end

  def execute_command(command)
    stdout, stderr, status = Open3.capture3(command)
    raise_if_failed(stderr) unless status.success?
    stdout.strip
  end

  def full_file_path(file_path)
    execute_command("readlink -f #{file_path}")
  end

  def ensure_directory(path)
    dirname = File.dirname(path)
    FileUtils.mkdir_p(dirname) unless File.directory?(dirname)
  end

  private

  def raise_if_failed(stderr)
    raise "Error: could not execute command: #{stderr}"
  end
end

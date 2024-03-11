require 'open3'
require 'json'
require 'os'
require_relative './loggable'
require_relative './utilities'

class TelemetryTester
  include Loggable
  include Utilities

  def initialize; end

  [:start_process, :create_file, :update_file, :delete_file, :network_request].each do |method_name|
    define_singleton_method method_name do |*args|
      new.send(method_name, *args)
    end
  end

  def start_process(executable, args = '')
    if OS.mac?
      command = "open #{executable}"
      command += " #{args}" unless args&.empty?
    elsif OS.linux?
      command = "#{executable}"
      command += " #{args}" unless args&.empty?
    else
      raise 'Only linux and mac are supported.'
    end

    execute_command(command)
    write_process_start_logs(command: command)
  end

  def create_file(name, extension)
    filename = "#{name}.#{extension}"
    ensure_directory(filename)

    command = "touch #{filename}"
    execute_command(command)

    write_file_crud_logs(type: 'file-created', command: command, file_path: full_file_path(filename))
  end

  def update_file(file_path, content, write_mode = 'a')
    raise "Invalid write mode argument: #{write_mode}" unless ['a', 'o'].include?(write_mode.downcase)

    operator = write_mode.downcase == 'a' ? '>>' : '>'
    command = "echo '#{content}' #{operator} #{file_path}"
    execute_command(command)

    write_file_crud_logs(type: 'file-updated', command: command, file_path: full_file_path(file_path))
  end

  def delete_file(file_path)
    full_path = full_file_path(file_path)
    command = "rm #{full_path}"
    execute_command(command)
    write_file_crud_logs(type: 'file-deleted', command: command, file_path: full_path)
  end

  def network_request(data)
    url = 'https://httpbin.org/post'
    command = "curl -H 'Content-Type: application/json' -d #{json_data(data)} POST #{url}"

    execute_command(command)

    write_network_request_logs(
      type: 'network-request',
      command: command.gsub(/(\s+)/, ' ').strip,
      request_info: {
        protocol: 'https',
        destination: "#{url}:443",
        source: "#{execute_command("curl ifconfig.me")}:443",
        data_size: data.to_json.size,
      }
    )
  end

  private

  def json_data(data)
    valid_json?(data) ? data : data.to_json
  end

  def valid_json?(json)
    JSON.parse(json)
    true
  rescue JSON::ParserError, TypeError => _e
    false
  end
end

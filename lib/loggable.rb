require 'open3'
require 'date'
require 'json'
require_relative './utilities'

module Loggable
  include Utilities

  def base_logs(command)
    user, process = user_and_process_metadata

    {
      start_time: Time.now.utc.to_s,
      username: user,
      process_name: process,
      command_line: command,
      pid: Process.pid,
    }
  end

  def write_process_start_logs(command:)
    log_info = base_logs(command)
    write_log_file('process-start', log_info)
    log_info
  end

  def write_file_crud_logs(type:, command:, file_path:)
    log_info = base_logs(command)
    log_info.merge!(
      file_path: file_path,
      descriptor: type
    )
    write_log_file(type, log_info)
    log_info
  end

  def write_network_request_logs(type:, command:, request_info:)
    log_info = base_logs(command).merge(request_info)
    write_log_file(type, log_info)
    log_info
  end

  private

  def write_log_file(type, info)
    timestamp = Time.now.utc.strftime('%Y%m%d-%H%M%S')
    filename = "./logs/#{type}-#{timestamp}.json"
    create_file_with_contents(filename, info.to_json)
  end

  def user_and_process_metadata
    execute_command("ps -p #{Process.pid} -o user= -o ucomm=")&.split(' ')
  end
end

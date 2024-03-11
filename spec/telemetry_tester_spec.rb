require 'spec_helper'
require 'os'
require_relative '../telemetry_tester'
require_relative '../utilities'

RSpec.describe TelemetryTester do
  let(:tester) { described_class.new }

  describe '#start_process' do
    context 'MacOS' do
      let(:executable) { 'some/path' }

      before do
        allow(OS).to receive(:mac?).and_return(true)
        allow(OS).to receive(:linux?).and_return(false)
      end

      it 'executes a command for the given executable' do
        expect(tester).to receive(:execute_command).with("open #{executable}")
        expect(tester).to receive(:execute_command).and_call_original

        tester.start_process(executable)
      end

      it 'executes a command for the given executable with args' do
        expect(tester).to receive(:execute_command).with("open #{executable} -g")
        expect(tester).to receive(:execute_command).and_call_original

        tester.start_process(executable, '-g')
      end

      it 'writes a log file' do
        allow_any_instance_of(described_class).to receive(:execute_command)
        expect(File).to receive(:open).with(include('process-start'), 'w')

        tester.start_process(executable)
      end
    end

    context 'Linux' do
      let(:executable) { 'some/path' }

      before do
        allow(OS).to receive(:mac?).and_return(false)
        allow(OS).to receive(:linux?).and_return(true)
      end

      it 'executes a command for the given executable' do
        expect(tester).to receive(:execute_command).with(executable)
        expect(tester).to receive(:execute_command).and_call_original

        tester.start_process(executable)
      end

      it 'executes a command for the given executable with args' do
        expect(tester).to receive(:execute_command).with("#{executable} -g")
        expect(tester).to receive(:execute_command).and_call_original

        tester.start_process(executable, '-g')
      end

      it 'writes a log file' do
        allow(tester).to receive(:execute_command)
        expect(File).to receive(:open).with(include('process-start'), 'w')

        tester.start_process(executable)
      end
    end
  end

  describe '#create_file' do
    let(:name) { 'foo/bar' }
    let(:extension) { 'txt' }

    context 'MacOS and Linux' do
      it 'executes a command to create a file from given arguments' do
        expected_filename = "#{name}.#{extension}"

        expect(tester)
          .to receive(:execute_command)
          .with("touch #{expected_filename}")
        expect(tester)
          .to receive(:execute_command)
          .with("readlink -f #{expected_filename}")
          .and_return(expected_filename)
        expect(tester)
          .to receive(:execute_command)
          .and_call_original

        tester.create_file(name, extension)
      end

      it 'writes a log file' do
        allow(tester).to receive(:execute_command)
        expect(File).to receive(:open).with(include('file-created'), 'w')

        tester.create_file(name, extension)
      end
    end
  end

  describe '#update_file' do
    let(:file_path) { 'foo/bar.txt' }
    let(:content) { 'Some content here' }

    context 'MacOS and Linux' do
      context 'in default append mode' do
        it 'executes a command to update a file from given arguments' do
          expect(tester)
            .to receive(:execute_command)
            .with("echo '#{content}' >> #{file_path}")
          expect(tester)
            .to receive(:execute_command)
            .with("readlink -f #{file_path}")
            .and_return(file_path)
          expect(tester)
            .to receive(:execute_command)
            .and_call_original

          tester.update_file(file_path, content)
        end
      end

      context 'with an arg for overwrite mode' do
        it 'executes a command to update a file from given arguments' do
          expect(tester)
            .to receive(:execute_command)
            .with("echo '#{content}' > #{file_path}")
          expect(tester)
            .to receive(:execute_command)
            .with("readlink -f #{file_path}")
            .and_return(file_path)
          expect(tester)
            .to receive(:execute_command)
            .and_call_original

          tester.update_file(file_path, content, 'o')
        end
      end

      context 'with an invalid arg for write mode' do
        it 'raises an error' do
          expect { tester.update_file(file_path, content, 'derp') }
            .to raise_error(/Invalid write mode argument/)
        end
      end

      it 'writes a log file' do
        allow(tester).to receive(:execute_command)
        expect(File).to receive(:open).with(include('file-updated'), 'w')

        tester.update_file(file_path, content)
      end
    end
  end

  describe '#delete_file' do
    let(:file_path) { 'foo/bar.txt' }

    context 'MacOS and Linux' do
      it 'executes a command to delete the given file' do
        expect(tester)
          .to receive(:execute_command)
          .with("rm #{file_path}")
        expect(tester)
          .to receive(:execute_command)
          .with("readlink -f #{file_path}")
          .and_return(file_path)
        expect(tester)
          .to receive(:execute_command)
          .and_call_original

        tester.delete_file(file_path)
      end

      it 'writes a log file' do
        allow(tester).to receive(:execute_command)
        expect(File).to receive(:open).with(include('file-deleted'), 'w')

        tester.delete_file(file_path)
      end
    end
  end

  describe '#network_request' do
    let(:data) { { name: 'John Smith'} }

    context 'MacOS and Linux' do
      context 'given data as a ruby hash' do
        it 'executes a command to make a network request to POST the given data as JSON' do
          expect(tester)
            .to receive(:execute_command)
            .with("curl -H 'Content-Type: application/json' -d #{data.to_json} POST https://httpbin.org/post")
          expect(tester)
            .to receive(:execute_command)
            .and_call_original
            .at_least(1).time

          tester.network_request(data)
        end
      end

      context 'given data as JSON' do
        it 'executes a command to make a network request to POST the given data' do
          json_data = data.to_json
          expect(tester)
            .to receive(:execute_command)
            .with("curl -H 'Content-Type: application/json' -d #{json_data} POST https://httpbin.org/post")
          expect(tester)
            .to receive(:execute_command)
            .and_call_original
            .at_least(1).time

          tester.network_request(json_data)
        end
      end

      it 'writes a log file' do
        allow(tester).to receive(:execute_command)
        expect(File).to receive(:open).with(include('network-request'), 'w')

        tester.network_request(data)
      end
    end
  end
end

require "test_helper"
require "open3"
require "socket"

class ShakapackerDevServerProxyTest < ActiveSupport::TestCase
  test "development assets use the configured backend instead of the request host" do
    server = TCPServer.new("127.0.0.1", 0)
    backend = Thread.new do
      loop do
        client = server.accept
        request = client.gets
        unless request
          client.close
          next
        end
        client.gets until $_ == "\r\n"
        client.write("HTTP/1.1 200 OK\r\nContent-Length: 13\r\nConnection: close\r\n\r\nwindow.ok=1;\n")
        client.close
        break
      end
    end

    script = <<~RUBY_SCRIPT
      require "rack/mock"
      entry = Rails.application.middleware.find { |middleware| middleware.klass == Shakapacker::DevServerProxy }
      proxy = entry.klass.new(->(_env) { [404, {}, ["fallback"]] }, *entry.args)
      response = Rack::MockRequest.new(proxy).get("/packs/probe.js", "HTTP_HOST" => "attacker.invalid")
      abort "Unexpected proxy response: \#{response.status}" unless response.status == 200 && response.body == "window.ok=1;\\n"
    RUBY_SCRIPT
    output, status = Open3.capture2e(
      { "RAILS_ENV" => "development", "SHAKAPACKER_DEV_SERVER_HOST" => "127.0.0.1",
        "SHAKAPACKER_DEV_SERVER_PORT" => server.addr[1].to_s },
      RbConfig.ruby, Rails.root.join("bin/rails").to_s, "runner", script
    )
    assert status.success?, output
  ensure
    backend&.kill
    backend&.join
    server&.close
  end
end

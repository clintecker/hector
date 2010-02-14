module Hector
  class IntegrationTest < TestCase
    def setup
      reset!
    end

    def teardown
      reset!
    end

    def reset!
      Identity.filename = IDENTITY_FIXTURES
      Identity.reset!
      Session.reset!
    end

    def authenticated_connection(nickname = "sam")
      connection.tap do |c|
        authenticate! c, nickname
      end
    end

    def authenticate!(connection, nickname)
      pass! connection
      user! connection
      nick! connection, nickname
    end

    def pass!(connection, password = "secret")
      connection.receive_line("PASS #{password}")
    end

    def user!(connection, username = "sam", realname = "Sam Stephenson")
      connection.receive_line("USER #{username} * 0 :#{realname}")
    end

    def nick!(connection, nickname = "sam")
      connection.receive_line("NICK #{nickname}")
    end

    def connection_nickname(connection)
      connection.instance_variable_get(:@nickname)
    end

    def assert_sent_to(connection, line)
      assert connection.sent_data =~ /^#{Regexp.escape(line)}/
    end

    def assert_welcomed(connection)
      assert_sent_to connection, "001 #{connection_nickname(connection)} :"
    end

    def assert_no_such_nick_or_channel(connection, nickname)
      assert_sent_to connection, "401 #{nickname} :"
    end

    def assert_nickname_in_use(connection)
      assert_sent_to connection, "433 #{connection_nickname(connection)} :"
    end

    def assert_invalid_password(connection)
      assert_sent_to connection, "464 :"
    end

    def assert_closed(connection)
      assert connection.connection_closed?
    end

    def assert_not_closed(connection)
      assert !connection.connection_closed?
    end
  end
end
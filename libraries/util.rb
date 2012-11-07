module PostgresqlCookbook
    module Util
        def self.truish? value
            [ '1', 'true', 'yes', 'on' ].include? value.to_s
        end
    end
end

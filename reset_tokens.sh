rails runner "ActiveRecord::Base.logger = Logger.new(STDOUT); ApiToken.destroy_all"
rails runner "ActiveRecord::Base.logger = Logger.new(STDOUT); ApiTokenArea.destroy_all"

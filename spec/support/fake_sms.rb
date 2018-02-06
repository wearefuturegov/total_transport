require 'active_support/all'

class FakeSMS
  cattr_accessor :messages
  self.messages = []

  def initialize
  end
  
  def api
    self
  end
  
  def account
    self
  end

  def messages
    self
  end

  def create(params)
    self.class.messages << {
      from: params[:from],
      to: params[:to],
      body: params[:body]
    }
  end
end

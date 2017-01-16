module MessagesHelper
  TEST_NUMBER = "+61411111111"

  def messaging_client
    client = ClickSend::REST::Client.new(:username => Rails.application.config.clicksend_username, :api_key => Rails.application.config.clicksend_api_key)
  end

  def send_activation_code(mobile)
    session.delete :activation_code
    client = messaging_client
    code = Random.new.rand(100000..999999)
    message = "Estater: Your activation code is #{code}. Do not reply by SMS."
    result = client.messages.send(:to => TEST_NUMBER, :message => message, :senderid => "Estater")
    return code if result["messages"].first["result"] == "0000"
  end
end

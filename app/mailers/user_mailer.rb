class UserMailer < ApplicationMailer
  def welcome
    @name = params[:name]
    mail(to: params[:to], from: "admin@example.com", subject: "Registration completed")
  end
end
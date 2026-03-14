class UserMailer < ApplicationMailer
  def welcome
    @name = params[:name]
    mail(to: params[:to], subject: "Registration completed")
  end
end
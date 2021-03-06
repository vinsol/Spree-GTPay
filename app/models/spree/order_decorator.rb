Spree::Order.class_eval do

  has_many :gtpay_transactions

  def gtpay_payment
    @gtpay_payment_method = Spree::Gateway::Gtpay.where(:environment => Rails.env).first
    payments.where("payment_method_id = #{@gtpay_payment_method.id} and state in ('checkout', 'processing', 'pending')").first if @gtpay_payment_method
  end

  def complete_and_finalize
    gtpay_payment.process_and_complete!

    update_attributes({:state => "complete", :completed_at => Time.current}, :without_protection => true)
    finalize!
  end

  def set_failure_for_payment
    gtpay_payment.started_processing!
    gtpay_payment.failure!
  end
end
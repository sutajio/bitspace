module Delayed
  module MessageSending
    module ClassMethods
      def handle_asynchronously(method, options = {})
        without_name = "#{method}_without_send_later"
        define_method("#{method}_with_send_later") do |*args|
          Delayed::Job.enqueue(
            Delayed::PerformableMethod.new(self, without_name.to_sym, args),
            options[:priority] || 0,
            options[:run_at].is_a?(Proc) ? options[:run_at].call : options[:run_at])
        end
        alias_method_chain method, :send_later
      end
    end
  end
end
class ActiveRecord::Base
  def self.validates_email(*args)
    
    if !args.empty? and args.last.is_a?(Hash)
      options = args.pop
    else
      options = { :presence => true }
    end
    
    args.each do |attribute|
      validates_as_email_address attribute.to_sym, options
      if options.include?( :presence )
        validates attribute.to_sym, options.reject{ |key,value| key != :presence }
      end
    end
    
  end
end
module VirtDisk
  # Utility module used by VirtDisk plug-ins, allowing them to export methods upstream.
  #
  # Typically, VirtDisk plug-ins are linked in a chain - each plug-in communicating with
  # the plug-in immediately upstream from it (where upstream is closer to the source of the data).
  # The last downstream plug-in (the volume head) is the object accessed directly by the client.
  #
  # This module enables upstream plug-ins to export methods, so they can be called directly
  # from the volume head.
  #
  # @note Every plug-in class must include this module, even if they don't export any methods.
  module ExportMethods
    module ClassMethods
      # Export one or more methods, making them callable from the volume head.
      #
      # @param syms [Symbol] the names of one or more methods to be exported.
      # @raise [RuntimeError] if any of the methods aren't defined in the class.
      def export(*syms)
        syms.each do |s|
          sym = s.to_sym
          raise "Method not defined in class: #{sym}" unless method_defined?(sym)
          return nil if exports.include?(sym)
          exports << sym
        end
        nil
      end

      # @return [Array<Symbol>] array of exported methods.
      def exports
        @__exported_methods ||= []
      end

      # @param sym [Symbol]
      # @return [Boolean] - true if sym is exported by this class, false otherwise.
      def exported?(sym)
        exports.include?(sym.to_sym)
      end
    end

    def self.included(host_class)
      host_class.extend(ClassMethods)
    end

    # Set the module immediately upstream from this one.
    #
    # @param obj [Object] the upstream module.
    def delegate=(obj)
      @__delegate = obj
    end

    # The module immediately upstream from this one.
    #
    # @return [Object] the module immediately upstream from this one.
    def delegate
      @__delegate
    end

    # @param sym [Symbol]
    # @return [Boolean] - true if sym is exported by this module's class, false otherwise.
    def exported?(sym)
      self.class.exported?(sym)
    end

    def respond_to_missing?(sym, include_all = false)
      return false unless @__delegate
      @__delegate.exported?(sym) || @__delegate.send(:respond_to_missing?, sym, include_all)
    end

    def method_missing(sym, *args)
      super unless respond_to_missing?(sym)
      @__delegate.send(sym, *args)
    end
  end
end

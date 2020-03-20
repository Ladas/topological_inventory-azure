module TopologicalInventory::Azure
  class Iterator
    attr_reader :block, :error_message, :log

    def initialize(blk, error_message)
      @block         = blk
      @error_message = error_message
      @log           = Logger.new(STDOUT)
    end

    def each
      block.call do |entity|
        yield(entity)
      end
    rescue StandardError => e
      log.error("#{error_message}. Message: #{e.message} #{e.backtrace.join('/n')}")
      []
    end
  end
end

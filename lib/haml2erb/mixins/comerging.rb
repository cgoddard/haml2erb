module Haml2Erb
  module Mixins
    module CoMerging
      def comerge
        # NOT IMPLEMENTED YET
        fail "comerge command not implemented yet"
      end

      # inclusive merge that combines results of two hashes when merging
      def comerge! hash_b
        hash_a = self
        hash_b.respond_to?(:each_pair) && hash_b.each_pair do |k,v|
          hash_a[k] = hash_a[k] ?
            (hash_a[k].respond_to?(:push) ?
              hash_a[k].push(v) :
              [ hash_a[k], v ]) :
            v
        end
      end
    end
  end
end
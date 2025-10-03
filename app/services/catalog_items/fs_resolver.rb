# app/services/catalog_items/fs_resolver.rb
module CatalogItems
  class FsResolver
    class << self
      def brand_root(brand)
        File.join(DomainRegistry.yml_root_service, "01_#{DomainRegistry.slug_from_host(brand['host'])}")
      end

      def list(brand, folders, key)
        root = resolve_ordered_path(brand, folders) || brand_root(brand)
        Dir.glob(File.join(root, "**", "*_#{key}_*.yml")).sort
      end

      def folders_from_path(path, brand)
        root = brand_root(brand)
        dir  = File.dirname(path)
        rel  = dir.sub(/\A#{Regexp.escape(root)}\/?/, "")
        # ripulisci i prefissi "NN_"
        rel.split("/").map { |seg| seg.sub(/\A\d+_/, "") }.join("/")
      end

      # ========== copia le utilità resolve_ordered_path/... già fornite ==========
      def resolve_ordered_path(brand, folders)
        base = brand_root(brand)
        segments = folders.to_s.split("/").reject(&:blank?)
        cur = base
        segments.each do |seg|
          cur = resolve_ordered_dir(cur, seg)
          return nil unless cur
        end
        cur
      end

      def resolve_ordered_dir(base_path, segment)
        return base_path if segment.blank?
        wanted = segment.to_s
        exact = Dir.children(base_path)
                   .select { |d| File.directory?(File.join(base_path, d)) }
                   .find { |d| d =~ /\A\d+_#{Regexp.escape(wanted)}\z/ }
        return File.join(base_path, exact) if exact
        no_prefix = File.join(base_path, wanted)
        return no_prefix if Dir.exist?(no_prefix)
        nil
      end
    end
  end
end

module SimpleDslParser
  module DSL
    require 'digest'

    class VenomFile
      REQUIRED_ATTRS ||= %i[name version git commit tag path branch].freeze
      attr_accessor(*REQUIRED_ATTRS)

      OPTIONAL_ATTRS ||= %i[configurations modular_headers subspecs inhibit_warnings testspecs].freeze
      attr_accessor(*OPTIONAL_ATTRS)

      attr_accessor(:customization, :config, :venom_config, :file_path, :binary, :changeable, :use_module_map, :use_swift_lint)

      def initialize
        yield self if block_given?
        if !@binary.nil?
          @changeable = false
        else
          @binary = true
          @changeable = true
        end
        if @use_module_map.nil?
          @use_module_map = false
        end
        if @use_swift_lint.nil?
          @use_swift_lint = false
        end
      end

      def md5
        Digest::MD5.hexdigest File.read(file_path)
      end

      def ==(other)
        self.class == other.class && md5 == other.md5
      end

      def source?
        source = customization && customization['source'] == true
        path = customization && customization['path']
        tag = customization && customization['tag']
        commit = customization && customization['commit']
        branch = customization && customization['branch']

        source || path || tag || commit || branch
      end

      def to_json
        to_hash.to_json
      end

      def to_hash
        hash = {}
        (REQUIRED_ATTRS + OPTIONAL_ATTRS).each do |att|
          value = send att
          hash[att.to_s] = value unless value.nil?
        end
        hash['binary'] = @binary
        hash['changeable'] = @changeable
        hash['use_module_map'] = @use_module_map
        hash['use_swift_lint'] = @use_swift_lint
        hash
      end

      def self.eval_with_string(content)
        eval(content)
      end

      def self.eval_with_filepath(filepath)
        return nil unless File.exist?(filepath)
        eval_with_string(File.read(filepath))
      end

      def write_to_file(filepath, source = false)
        if File.exist?(filepath)
          backup = "#{filepath}.backup"
          FileUtils.copy_file(filepath, backup)
          FileUtils.remove_file(filepath)
        end

        File.open(filepath, 'w+') do |f|
          begin
            lines = []
            lines << 'VenomFile.new do |v|'
            lines << "  v.name = \"#{name}\"" unless name.nil?
            lines << "  v.version = \"#{version}\"" unless version.nil?
            lines << "  v.git = \"#{git}\"" unless git.nil?
            lines << "  v.commit = \"#{commit}\"" unless commit.nil?
            lines << "  v.tag = \"#{tag}\"" unless tag.nil?
            lines << "  v.path = \"#{path}\"" unless path.nil?
            lines << "  v.branch = \"#{branch}\"" unless branch.nil?

            lines << "  v.configurations = #{configurations}" if configurations
            lines << "  v.modular_headers = #{modular_headers}" if modular_headers
            lines << "  v.subspecs = #{subspecs}" if subspecs
            lines << "  v.testspecs = #{testspecs}" if testspecs
            lines << "  v.inhibit_warnings = #{inhibit_warnings}" unless inhibit_warnings.nil?
            if !binary || source
              lines << '  v.binary = false'
            elsif binary
              lines << '  v.binary = true'
            end
            pp "use_module_map: #{use_module_map}"
            lines << "  v.use_module_map = #{use_module_map}" if use_module_map
            lines << "  v.use_swift_lint = #{use_swift_lint}" if use_swift_lint

            lines << "end\n"

            f.write(lines.join("\n"))
            # pp lines.join("\n")
          rescue Exception => e
            UI.error "❌ exceptions: #{e}"
            if File.exist?(backup)
              File.write(filepath, File.read(backup), mode: 'w')
            end
          end
        end

        FileUtils.remove_file(backup)
      end
    end
  end
end

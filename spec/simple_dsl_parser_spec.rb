require 'pp'

RSpec.describe SimpleDslParser do
  # it "has a version number" do
  #   expect(SimpleDslParser::VERSION).not_to be nil
  # end

  # it "does something useful" do
  #   expect(false).to eq(true)
  # end

  it "VenomFile - read" do
    venom = SimpleDslParser::DSL::VenomFile.eval_with_filepath("spec/BangcleCryptoTool.rb")
    pp venom

    expect(venom.name).to eq('BangcleCryptoTool')
    expect(venom.git).to eq('git@git.in.xxx.com:Team-iOS-Platform/BangcleCryptoTool.git')
    expect(venom.tag).to eq('1.2.3')
    expect(venom.inhibit_warnings).to eq(false)
    expect(venom.binary).to eq(false)
  end

  it "VenomFile - write" do
    origin_venom = SimpleDslParser::DSL::VenomFile.eval_with_filepath("spec/BangcleCryptoTool.rb")
    origin_venom.tag = '2.2.0'
    origin_venom.write_to_file("spec/BangcleCryptoTool_backup.rb")
    pp "💚 " * 30
    pp origin_venom
    
    modify_venom = SimpleDslParser::DSL::VenomFile.eval_with_filepath("spec/BangcleCryptoTool_backup.rb")
    pp "💜 " * 30
    pp modify_venom

    expect(origin_venom.name).to eq(modify_venom.name)
    expect(origin_venom.git).to eq(modify_venom.git)
    expect(modify_venom.tag).to eq('2.2.0')
    expect(origin_venom.inhibit_warnings).to eq(modify_venom.inhibit_warnings)
    expect(origin_venom.use_swift_lint).to eq(modify_venom.use_swift_lint)
    expect(origin_venom.binary).to eq(modify_venom.binary)
    expect(origin_venom.use_module_map).to eq(modify_venom.use_module_map)
  end
end

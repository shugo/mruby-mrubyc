MRuby::Gem::Specification.new('mruby-mrubyc') do |spec|
  spec.license = 'MIT'
  spec.authors = 'HASUMI Hitoshi'
  spec.summary = 'mruby/c library'

  mrubyc_dir = "#{dir}/repos/mrubyc"

  file mrubyc_dir do
    FileUtils.cd "#{dir}/repos" do
      sh "git clone -b mrubyc3 https://github.com/mrubyc/mrubyc.git"
    end
    FileUtils.cd "#{dir}/repos/mrubyc" do
      sh "git checkout 0f22570"
    end
  end

  mrubyc_srcs = %w(alloc   c_math    c_range  console keyvalue rrt0    vm
                   c_array c_numeric c_string error   load     symbol
                   c_hash  c_object  class    global  value)
  begin
    hal_dir = cc.defines.find{ |d|
      d.include? "MRBC_USE_HAL_"
    }.match(/\A(MRBC_USE_)(.+)\z/)[2].downcase
  rescue => NoMethodError
    raise "\nError!\nMRBC_USE_something must be defined in build_config!\n\n"
  end
  mrubyc_srcs << "#{hal_dir}/hal"

  mrubyc_srcs.each do |mrubyc_src|
    file objfile("#{build_dir}/src/#{mrubyc_src}") => "#{mrubyc_dir}/src/#{mrubyc_src}.c" do |f|
      cc.run f.name, f.prerequisites.first
    end
    file "#{mrubyc_dir}/src/#{mrubyc_src}.c" => mrubyc_dir
  end

  file "#{mrubyc_dir}/mrblib" => mrubyc_dir

  file "#{build_dir}/src/mrblib.c" => "#{mrubyc_dir}/mrblib" do |f|
    mrblib_sources = Dir.glob("#{mrubyc_dir}/mrblib/*.rb").join(" ")
    sh "#{build.mrbcfile} -B mrblib_bytecode -o #{f.name} #{mrblib_sources}"
  end

  file objfile("#{build_dir}/src/mrblib") => "#{build_dir}/src/mrblib.c" do |f|
    cc.run f.name, f.prerequisites.first
  end

end

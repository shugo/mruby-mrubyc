MRuby::Gem::Specification.new('mruby-mrubyc') do |spec|
  spec.license = 'MIT'
  spec.authors = 'HASUMI Hitoshi'
  spec.summary = 'mruby/c library'

  file "#{dir}/repos/mrubyc" do
    FileUtils.cd "#{dir}/repos" do
      sh "git clone -b mrubyc3 https://github.com/mrubyc/mrubyc.git"
    end
  end

  mrubyc_srcs = %w(alloc   c_math    c_range  console keyvalue rrt0    vm
                   c_array c_numeric c_string error   load     symbol
                   c_hash  c_object  class    global  value    hal_posix/hal)
  mrubyc_srcs.each do |mrubyc_src|
    file objfile("#{build_dir}/src/#{mrubyc_src}") => "#{dir}/repos/mrubyc/src/#{mrubyc_src}.c" do |f|
      cc.run f.name, f.prerequisites.first
    end
  end

  file "#{dir}/repos/mrubyc/mrblib" => "#{dir}/repos/mrubyc"

  file "#{build_dir}/src/mrblib.c" => "#{dir}/repos/mrubyc/mrblib" do |f|
    mrblib_sources = Dir.glob("#{dir}/repos/mrubyc/mrblib/*.rb").join(" ")
    sh "#{build.mrbcfile} -B mrblib_bytecode -o #{f.name} #{mrblib_sources}"
  end

  file objfile("#{build_dir}/src/mrblib") => "#{build_dir}/src/mrblib.c" do |f|
    cc.run f.name, f.prerequisites.first
  end

end

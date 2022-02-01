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

  file "#{dir}/mrblib/mrblib.c" => "#{dir}/repos/mrubyc/mrblib" do |f|
    mrblib_sources = Dir.glob("#{dir}/repos/mrubyc/mrblib/*.rb").join(" ")
    sh "#{build.mrbcfile} -B mrblib_bytecode -o #{dir}/src/mrblib.c #{mrblib_sources}"
  end

  task :copy_mrubyc_headers => "#{dir}/repos/mrubyc" do
    sh "mkdir -p #{build_dir}/src"
    sh "cp #{dir}/repos/mrubyc/src/*.h #{build_dir}/src/"
    sh "mkdir -p #{build_dir}/src/hal_posix"
    sh "cp #{dir}/repos/mrubyc/src/hal_posix/hal.h #{build_dir}/src/hal_posix/"
  end

  Rake::Task[:copy_mrubyc_headers].invoke
  mrubyc_srcs.each do |mrubyc_src|
    Rake::Task[objfile("#{build_dir}/src/#{mrubyc_src}")].invoke
  end
  Rake::Task[objfile("#{build_dir}/src/hal_posix/hal")].invoke
end

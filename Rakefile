work_dir = File.dirname(__FILE__)
project_name = “AttendanceRecord”

desc "Xcodeでプロジェクトを開く"
task :open do
      sh "open #{project_name}.xcworkspace"
end

desc "Gem・Mock更新"
task :update do
      sh "bundle install"
        Rake::Task["build"].invoke
end

desc "初期セットアップ"
task :setup do
      sh "brew install rbenv ruby-build rbenv-gem-rehash rbenv-binstubs carthage"
        sh "echo 'if ! [[ $(which rbenv) =~ \"rbenv\" ]]; then eval \"$(rbenv init -)\" && source ~/.bash_profile; fi' >> ~/.bash_profile"
          sh "rbenv install `cat .ruby-version`" do |is_success, status|
                  p "WARN: ignore error." unless is_success
                    end
            sh "gem install bundler"
              Rake::Task["update"].invoke
end

desc "Carthageのリビルド"
task :build do
      sh "carthage build --platform iOS --no-use-binaries"
end

# ToDo
#desc 'COREアカウントの開発証明書・プロビのインストール'
#task :match do
#      sh 'match development --readonly'
#end

desc "Project-フォルダ同期"
task :synx do |t|
      sh "synx #{project_name}.xcodeproj/"
end

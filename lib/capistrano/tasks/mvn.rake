require 'sshkit'

module SSHKit

    module CommandHelper 

        def mvn_prepare
            # determine mvn location
            if !fetch(:m2_home).nil?
                SSHKit.config.command_map[:mvn] = "#{fetch(:m2_home)}/bin/mvn"
            else
                m2_home = capture('echo $M2_HOME')
                if m2_home != '' and test("[ -d #{m2_home} ]")
                    SSHKit.config.command_map[:mvn] = "#{m2_home}/bin/mvn"
                else
                    SSHKit.config.command_map[:mvn] = "env mvn"
                end
            end
        end

        def mvn(tasks=[])
            mvn_prepare
            execute :mvn, tasks
        end

        def mvn_parse_output(output)
            flag = false
            data = []
            output.split("\n").each do |line|
                if line.start_with?('[')
                    flag = false
                end
                if flag
                    data << line
                end
                if line.start_with?('[')
                    flag = true
                end
            end
            return data
        end

        def mvn_dependency_classpath
            mvn_prepare
            classpath_list = mvn_parse_output(capture(:mvn, 'dependency:build-classpath'))[0]
            return classpath_list.split(':')
        end

        def mvn_property(name)
            return mvn_parse_output(capture(:mvn, "help:evaluate -Dexpression=#{name}"))[0]
        end

        def mvn_project_version
            return mvn_property('project.version')
        end

        def mvn_project_build_directory
            return mvn_property('project.build.directory')
        end

        def mvn_project_build_final_name
            return mvn_property('project.build.finalName')
        end

        def mvn_project_packaging
            return mvn_property('project.packaging')
        end

        def mvn_project_file
            return mvn_property('project.file')
        end

        def mvn_project_artifact_path
            return "#{mvn_project_build_directory}#{File::SEPARATOR}#{mvn_project_build_final_name}.#{mvn_project_packaging}"
        end

        def basename(name)
            File.basename(name)
        end
        
        # compute md5sum
        def md5sum(file)
            return capture(:md5sum,file).split(' ')[0]
        end

        # deploy file
        def deploy(local_file, remote_file)
            # compute local file md5sum
            local_md5sum = nil
            run_locally do
                local_md5sum = md5sum(local_file)
            end
            # compute remote file md5sum
            remote_md5sum = 'nil'
            if test("[ -f #{remote_file} ]")
                remote_md5sum = md5sum(remote_file)
            end
            # check md5sums
            if local_md5sum != remote_md5sum
                # deploy file
                info "md5sums #{local_md5sum} #{remote_md5sum} do not match"
                info "deploy #{local_file} to #{remote_file}"
                upload!(local_file,remote_file)
            else
                info "#{remote_file} is up to date!"
            end
        end
        
        # deploy file remotely
        def remote_deploy(from_file, to_file)
            # compute from file md5sum
            from_md5sum = md5sum(from_file)
            # compute remote file md5sum
            to_md5sum = 'nil'
            if test("[ -f #{to_file} ]")
                to_md5sum = md5sum(to_file)
            end
            # check md5sums
            if from_md5sum != to_md5sum
                # deploy file
                info "md5sums #{from_md5sum} #{to_md5sum} do not match"
                info "deploy #{from_file} to #{to_file}"
                execute :cp, "#{from_file} #{to_file}"
            else
                info "#{to_file} is up to date!"
            end
        end

        # deploy directory recursively
        def deploy_directory(local_directory, remote_directory)
            execute :mkdir, "-p #{remote_directory}"
            Dir.foreach(local_directory) do |file|
                next if file == '.' or file == '..'
                path = "#{local_directory}#{File::SEPARATOR}#{file}"
                if File.directory?(path)
                    deploy_directory(path,"#{remote_directory}#{File::SEPARATOR}#{file}")
                else
                    deploy(path,"#{remote_directory}#{File::SEPARATOR}#{file}")
                end
            end
        end
        
        # remotely deploy directory recursively
        def remote_deploy_directory(from_directory, to_directory)
            execute :mkdir, "-p #{to_directory}"
            Dir.foreach(from_directory) do |file|
                next if file == '.' or file == '..'
                path = "#{from_directory}#{File::SEPARATOR}#{file}"
                if File.directory?(path)
                    remote_deploy_directory(path,"#{to_directory}#{File::SEPARATOR}#{file}")
                else
                    remote_deploy(path,"#{to_directory}#{File::SEPARATOR}#{file}")
                end
            end
        end

        # file list filter
        # returns only files that match any of patterns
        def only(files,patterns)
            if !patterns.kind_of?(Array)
                patterns = [patterns]
            end
            files.select do |file|
                matches = false
                patterns.each do |pattern|
                    if File.fnmatch(pattern,file)
                        matches = true
                        break
                    end
                end
                matches
            end
        end

        # file list filter
        # returns files except any that matches patterns
        def except(files,patterns)
            if !patterns.kind_of?(Array)
                patterns = [patterns]
            end
            files.select do |file|
                matches = true
                patterns.each do |pattern|
                    if File.fnmatch(pattern,file)
                        matches = false
                        break
                    end
                end
                matches
            end
        end
    end
end


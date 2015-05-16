currentVersion = 'v0.6.0'
module.exports = (grunt) ->

    grunt.config.init

        'mocha-chai-sinon':
            spec:
                src: [
                    'spec/**/*.coffee'
                    '!spec/domain/**/*'
                    '!spec/base-domain.coffee'
                    '!spec/init.coffee'
                    '!spec/fixtures/**/*'
                ]
                options:
                    ui: 'bdd'
                    reporter: 'spec'
                    require: 'coffee-script/register'

            single:
                src: [
                    grunt.option('file') ? 'spec/base-repository.coffee'
                ]
                options:
                    ui: 'bdd'
                    reporter: 'spec'
                    require: 'coffee-script/register'


        yuidoc:
            options:
                paths: ['src']
                syntaxtype: 'coffee'
                extension: '.coffee'
            master:
                options:
                    outdir: "doc/#{currentVersion}"


        coffee:
            dist:
                expand: true
                cwd: 'src/lib'
                src: ['**/*.coffee']
                dest: 'dist/lib/'
                ext: '.js'
                extDot: 'first'
                options:
                    bare: true





    grunt.loadNpmTasks 'grunt-mocha-chai-sinon'
    grunt.loadNpmTasks 'grunt-contrib-yuidoc'
    grunt.loadNpmTasks 'grunt-contrib-coffee'

    grunt.registerTask 'default', 'mocha-chai-sinon:spec'
    grunt.registerTask 'single', 'mocha-chai-sinon:single'
    grunt.registerTask 'build', ['coffee:dist']

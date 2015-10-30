module.exports = (grunt) ->

    grunt.config.init

        'mocha-chai-sinon':
            spec:
                src: [
                    'spec/lib/*.coffee'
                    'spec/util.coffee'
                    'spec/master-data-resource.coffee'
                    'spec/fixture.coffee'
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
                    outdir: 'doc'


        coffee:
            dist:
                expand: true
                cwd: 'src'
                src: ['**/*.coffee']
                dest: 'dist/'
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

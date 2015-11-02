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

            uglify_test:
                expand: true
                cwd: 'test/uglify-js/coffee'
                src: ['**/*.coffee']
                dest: 'test/uglify-js/build'
                ext: '.js'
                extDot: 'first'
                options:
                    bare: true


        copy:
            uglify_test:
                expand: true
                cwd: 'test/uglify-js/coffee'
                src: ['**/!(*.coffee)']
                dest: 'test/uglify-js/build'


        uglify:
            test:
                files:
                    'test/uglify-js/build/domain.min.js': 'test/uglify-js/build/**/*.js'



    grunt.loadNpmTasks 'grunt-mocha-chai-sinon'
    grunt.loadNpmTasks 'grunt-contrib-yuidoc'
    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-contrib-uglify'
    grunt.loadNpmTasks 'grunt-contrib-copy'

    grunt.registerTask 'default', 'mocha-chai-sinon:spec'
    grunt.registerTask 'single', 'mocha-chai-sinon:single'
    grunt.registerTask 'build', ['coffee:dist']
    grunt.registerTask 'uglify-test', ['coffee:uglify_test', 'copy:uglify_test', 'uglify:test']

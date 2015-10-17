# This is my personal take on a Gruntfile.
# Shut up.

# This the build lifecycle:
# serve (while developing) -> build -> dist

module.exports = (grunt) ->

	configuration =
		paths:
			src:       require("./bower.json").appPath or "src"
			build:     "build"
			generated: ".generated"


	require("time-grunt") grunt

	require("jit-grunt") grunt,
		useminPrepare: "grunt-usemin"


	grunt.initConfig

		# Make the configuration available to grunt.
		cfg: configuration


		# grunt-contrib-clean
		# Remove the build and .generated folders.
		clean: [
			"<%= cfg.paths.build %>",
			"<%= cfg.paths.generated %>"
		]


		# grunt-browser-sync
		# Starts a webserver and provides live reloading.
		browserSync:
			options:
				notify: false
				watchTask: true

			livereload:
				options:
					port: 9000

					files: [
							"<%= cfg.paths.src %>/{,*/}*.html"
							"<%= cfg.paths.src %>/images/{,*/}*"
							"<%= cfg.paths.generated %>/scripts/{,*/}*.js"
							"<%= cfg.paths.generated %>/styles/{,*/}*.css"
					]

					server:
						baseDir: ["<%= cfg.paths.generated %>", "<%= cfg.paths.src %>"]
						routes:
							"/bower_components": "./bower_components"


		# grunt-contrib-watch
		# Watches files for changes and executes grunt tasks.
		watch:
			coffee:
				files: ["<%= cfg.paths.src %>/scripts/{,*/}*.coffee"]
				tasks: ["coffeelint", "coffee"]

			compass:
				files: ["<%= cfg.paths.src %>/styles/{,*/}*.scss"]
				tasks: ["sass", "csslint"]

			gruntfile:
				files: ["Gruntfile.coffee"]
				tasks: ["coffeelint"]

			bower:
				files: ["bower.json"]
				tasks: ["wiredep"]


		# grunt-coffelint
		# Checks CoffeeScript files for common mistakes.
		coffeelint:
			options:
				configFile: "coffeelint.json"

			src: [
				"Gruntfile.coffee"
				"<%= cfg.paths.src %>/scripts/{,*/}*.coffee"
			]


		# grunt-contrib-csslint
		# Checks CSS files for common mistakes.
		csslint:
			src: ["<%= cfg.paths.generated %>/styles/{,*/}*.css"]


		# grunt-wiredep
		wiredep:
			build:
				options:
					directory: "bower_components"

				ignorePath: /^(\.\.\/)*\.\.\//
				src: [
					"<%= cfg.paths.src %>/{,/*}*.html"
					"<%= cfg.paths.src %>/styles/{,/*}.{sass,scss}"
				]


		# grunt-contrib-coffee
		# Compile CoffeeScript to JavaScript.
		coffee:
			build:
				expand: true
				cwd: "<%= cfg.paths.src %>/scripts"
				src: ["{,*/}*.coffee"]
				dest: "<%= cfg.paths.generated %>/scripts"
				ext: ".js"


		# grunt-contrib-sass
		# Compile sass to css.
		sass:
			build:
				expand: true
				cwd: "<%= cfg.paths.src %>/styles"
				src: ["{,*/}*.{scss,sass}"]
				dest: "<%= cfg.paths.generated %>/styles"
				ext: ".css"


		# grunt-svgmin
		# Minify SVG files.
		svgmin:
			options:
				plugins: [
					convertPathData: false
				]

			build:
				expand: true
				cwd: "<%= cfg.paths.src %>/images"
				src: ["{,*/}*.svg"]
				dest: "<%= cfg.paths.generated %>/images"


		# grunt-contrib-imagemin
		imagemin:
			build:
				expand: true
				cwd: "<%= cfg.paths.src %>/images"
				src: ["{,*/}*.{jpg,jpeg,png,gif}"]
				dest: "<%= cfg.paths.generated %>/images"


		# grunt-contrib-copy
		# Copy static files that don't require processing.
		copy:
			build:
				files: [
					{
						expand: true,
						cwd: "<%= cfg.paths.src %>"
						dest: "<%= cfg.paths.build %>"
						src: [
							"*.html"
							"robots.txt"
							".htaccess"
							".htpasswd"
							"favicon.ico"
						]
					}
					{
						expand: true,
						cwd: "<%= cfg.paths.generated %>"
						dest: "<%= cfg.paths.build %>"
						src: [
							"images/{,*/}*.{svg,jpeg,jpg,png,gif}"
						]
					}
				]


		# grunt-filerev
		filerev:
			options:
				algorithm: "md5"
				length: 8

			build:
				src: [
					"<%= cfg.paths.build %>/scripts/*.js"
					"<%= cfg.paths.build %>/styles/{,*/}*.css"
					"<%= cfg.paths.build %>/images/{,*/}*.{svg,png,jpeg,jpg,gif}"
					"<%= cfg.paths.build %>/fonts/{,*/}*.*"
					"<%= cfg.paths.build %>/*.{ico,png}"
				]


		# grunt-usemin
		useminPrepare:
			options:
				dest: "<%= cfg.paths.build %>"
				staging: "<%= cfg.paths.generated %>"
				root: "<%= cfg.paths.generated %>"

			html: "<%= cfg.paths.src %>/index.html"


		usemin:
			options:
				assetDirs: [
					"<%= cfg.paths.build %>"
					"<%= cfg.paths.build %>/images"
					"<%= cfg.paths.build %>/styles"
				]

			html: ["<%= cfg.paths.build %>/{,*/}*.html"]
			css: ["<%= cfg.paths.build %>/styles/{,*/}*.css"]


		# grunt-contrib-htmlmin
		htmlmin:
			build:
				options:
					collapseWhitespace: true
					collapseBooleanAttributes: true
					removeCommentsFromCDATA: true
					removeComments: true

				files: [
					expand: true
					cwd: "<%= cfg.paths.build %>"
					src: "{,*/}*.html"
					dest: "<%= cfg.paths.build %>"
				]


	grunt.registerTask("build", [
		"clean"
		"wiredep"
		"useminPrepare"
		"coffeelint"
		"sass"
		"csslint"
		"coffee"
		"svgmin"
		"imagemin"
		"copy:build"
		"concat"
		"cssmin"
		"uglify"
		"filerev"
		"usemin"
		"htmlmin:build"
	])

	grunt.registerTask("serve", [
		"coffeelint"
		"sass"
		"csslint"
		"coffee"
		"browserSync"
		"watch"
	])

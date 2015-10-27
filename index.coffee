program = require "commander"
chokidar = require 'chokidar'
_ = require "underscore"

program
  .version('0.1.0')
  .description("sync this repo w/ a remote")
  .option('-f --force', "force server to be identical to client")
  .option('-w --watch', "watch the project and sync on changes")
  .option('-v --verbose', "include debug output")
  .parse(process.argv)

Syncer = require("./lib/sync")

options = {watch: program.watch?, force: program.force?, verbose: program.verbose?}
repo = process.argv[process.argv.length - 1]

scanComplete = false

syncer = new Syncer(srcDir:process.cwd(), remote:repo, verbose: options.verbose)

display = (results)->
  results.then ({duration, updates})->
    console.log "#{update.action} #{update.filename}" for update in updates
    if updates.length == 0
      console.log "No changes were synced"
    console.log "Sync completed in #{duration/1000.0} seconds"

if options.watch
  watcher = chokidar.watch(process.cwd(), {})
  watcher.on 'all', (event, path)->
    #ignore objects created by syncer
    ignore = new RegExp("#{process.cwd()}/.git/objects|#{process.cwd()}/.git/refs/__git-n-sync__/head|#{process.cwd()}/.git/index-git-n-sync")
    unless ignore.exec(path)
      console.log("Chokidar event", event, path) if scanComplete and options.verbose
      # console.log("now sync")
      display(syncer.sync())

  watcher.on 'ready', ->
    # console.log("WATCHER IS READY")
    scanComplete = true

else
  display(syncer.sync())



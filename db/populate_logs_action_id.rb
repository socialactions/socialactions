# script to populate the action_id column in the logs table
# TO RUN: 
# RAILS_ENV=production script/runner 'load "db/populate_logs_action_id.rb"'

count = 0
already_set = 0
missing_redirects = 0
missing_actions = 0
couldnt_save = 0
done = false
i = 0
batchsize=10000
while(not done)
  lower = i * batchsize
  upper = (i + 1) * batchsize - 1
  puts "#{Time.now}: scanning log records with id between #{lower} and #{upper}..."
  thiscount = 0
  Shorturl::Log.find(:all, :conditions => ['id BETWEEN ? AND ?', lower, upper]).each do |log|
    count += 1
    thiscount += 1
    # if the action_id is already set for this log record, skip it.
    unless log.action_id.nil?
      already_set += 1
      next
    end
    # get the associated redirect record
    redirect = Shorturl::Redirect.find(:first, :conditions => ['id = ?', log.redirect_id])
    if redirect.nil?
      missing_redirects += 1
      next
    end
    # find the appropriate action record based on the redirect URL
    actions = Action.find(:all, :conditions => ['url = ?', redirect.url])
    if actions.nil? or actions.empty?
      missing_actions += 1
      next
    end
    # set the action_id for this log record
    log.action_id = actions.first.id
    unless log.save
      couldnt_save += 1
    end
    printf "#{count}... " if count % 1000 == 0 # progress
  end
  if thiscount == 0
    # no matching records were found in this batch
    RAILS_DEFAULT_LOGGER.info "no logs found with IDs between #{lower} and #{upper}, stopping script."
    puts "no logs found with IDs between #{lower} and #{upper}, stopping script."
    done = true
  else
    # move to the next batch
    i += 1
  end
end
puts "Summary:"
puts "Total Logs records: #{count}"
puts "Logs with action_id already set: #{already_set}"
puts "Logs with missing Redirect records: #{missing_redirects}"
puts "Logs/Redirects with missing Actions records: #{missing_actions}"
puts "Logs errors during save: #{couldnt_save}"
puts "done."

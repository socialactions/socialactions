class AddActionIdToLogs < ActiveRecord::Migration
  def self.up
    add_column :logs, :action_id, :integer
    count = 0
    missing_redirects = 0
    missing_actions = 0
    couldnt_save = 0
    Shorturl::Log.find(:all).each do |log|
      count += 1
      redirect = Shorturl::Redirect.find(:first, :conditions => ['id = ?', log.redirect_id])
      if redirect.nil?
        missing_redirects += 1
        next
      end
      actions = Action.find(:all, :conditions => ['url = ?', redirect.url])
      if actions.nil? or actions.empty?
        missing_actions += 1
        next
      end
      # for this log
      log.action_id = actions.first.id
      unless log.save
        couldnt_save += 1
      end
      puts "#{count}... " if count % 10000 == 0 # progress
    end
    puts "Summary:"
    puts "Total Logs records: #{count}"
    puts "Logs with missing Redirect records: #{missing_redirects}"
    puts "Logs/Redirects with missing Actions records: #{missing_actions}"
    puts "Logs errors during save: #{couldnt_save}"
    puts "done."
  end

  def self.down
    remove_column :logs, :action_id
  end
end

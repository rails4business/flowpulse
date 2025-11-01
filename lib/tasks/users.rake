# lib/tasks/users.rake
namespace :users do
  desc "Delete pending users with no sessions older than 14 days (and orfani Lead)"
  task cleanup_pending: :environment do
    cutoff = 14.days.ago
    to_delete = User.inactive_pending(older_than: cutoff)
    count = to_delete.count
    Lead.where(user_id: to_delete.select(:id)).update_all(user_id: nil)
    to_delete.delete_all
    puts "Deleted #{count} pending users without sessions older than #{cutoff}."
  end
end

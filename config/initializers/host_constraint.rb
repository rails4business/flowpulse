# config/initializers/host_constraint.rb
class HostConstraint
  def self.normalize_host(host)
    host.to_s.downcase.sub(/\Ahttps?:\/\//, "").split(":").first.to_s.sub(/\Awww\./, "")
  end

  def initialize(base_host)
    @base_host = self.class.normalize_host(base_host)
  end

  def matches?(req)
    h = self.class.normalize_host(req.host)
    h == @base_host || h.end_with?(".#{@base_host}")
  end
end

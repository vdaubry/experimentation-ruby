require 'aws-sdk'

puts "Initializing AWS conf"
Aws.config.update({
  region: 'us-west-2',
  credentials: Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
})

puts "Initiate a client in the Ireland region"
ec2 = Aws::EC2::Client.new(region: 'eu-west-1')

puts "Request instance"
spot_request = ec2.request_spot_instances(
  spot_price: "0.0150",
  instance_count: 1,
  type: "one-time",
  launch_specification: {
    image_id: 'ami-61ea8716',
    key_name: "youboox_EC2_deploy",
    security_group_ids: ["sg-cec494ab"],
    instance_type: 'm3.medium',
    block_device_mappings: [
    {
      device_name: "/dev/sda1",
      ebs: {
        volume_size: 60
      }
    }],
    subnet_id: "subnet-7e718809"
  }
)

spot_instance_request_id = spot_request[0][0].spot_instance_request_id

wait_timeout = 300
max_attenpts = 50
puts "Waiting for spot_request to fullfill, timeout = #{wait_timeout}"
begin
  ec2.wait_until(:spot_instance_request_fulfilled, spot_instance_request_ids:[spot_instance_request_id]) do |w|
    w.max_attempts = max_attenpts
    w.interval = wait_timeout/max_attenpts
    
    w.before_attempt do |n|
      puts "Instance not running yet, attempt n° #{n}, next attempt in #{wait_timeout/max_attenpts} sec"
    end
  end
rescue Aws::Waiters::Errors::WaiterFailed
  puts "Instance start timeout"
  exit
end

spot_requests = ec2.describe_spot_instance_requests(spot_instance_request_ids: [spot_instance_request_id])
instance_id = spot_requests[0][0].instance_id
puts "Instance request successfull, instance id is : #{instance_id}"

wait_time=40
puts "Waiting for instance boot to finish"
wait_time.times { print "."; sleep(1)}

ec2.associate_address(
  instance_id: instance_id,
  allocation_id: "eipalloc-7e3fc71b",
  allow_reassociation: true
)

elastic_ips = ec2.describe_addresses(allocation_ids: ["eipalloc-7e3fc71b"])
public_ip = elastic_ips[0][0].public_ip
puts "Instance public IP is : #{public_ip}"

#Trust SSH connection for this instance
File.open("#{ENV['HOME']}/config", "w") do |f|
  f.write("#Allow EC2 Elastic IP" \
          "Host ec2-#{public_ip}.eu-west-1.compute.amazonaws.com" \
          " StrictHostKeyChecking no" \
          " UserKnownHostsFile /dev/null")
end
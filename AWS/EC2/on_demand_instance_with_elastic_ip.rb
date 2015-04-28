require 'aws-sdk'

puts "Initializing AWS conf"
Aws.config.update({
  region: 'us-west-2',
  credentials: Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
})

puts "Initiate a client in the Ireland region"
ec2 = Aws::EC2::Client.new(region: 'eu-west-1')

puts "Request instance"
instance_request = ec2.run_instances(
  image_id: 'ami-4b731e3c',
  instance_type: 'm3.medium',
  min_count: 1,
  max_count: 1,
  key_name: "youboox_EC2_deploy",
  security_group_ids: ["sg-cec494ab"],
  instance_initiated_shutdown_behavior: "terminate",
  subnet_id: "subnet-7e718809",
  block_device_mappings: [
    {
      device_name: "/dev/sda1",
      ebs: {
        volume_size: 60
      }
    }
  ])

instance_id = instance_request.instances.first.instance_id

wait_timeout = 60
puts "Waiting for instance to start, timeout = #{wait_timeout}"
begin
  ec2.wait_until(:instance_running, instance_ids:[instance_id]) do |w|
    w.max_attempts = 10
    w.interval = wait_timeout/10
    
    w.before_attempt do |n|
      puts "Instance not running yet, attempt n° #{n}, next attempt in #{wait_timeout/10} sec"
    end
  end
rescue Aws::Waiters::Errors::WaiterFailed
  puts "Instance start timeout"
  exit
end
puts "Instance request successfull, instance id is : #{instance_id}"


puts "Waiting for instance boot to finish"
wait_time=40
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
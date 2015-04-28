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
  image_id: 'ami-47a23a30',
  instance_type: 't2.micro',
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

public_dns = ec2.describe_instances(instance_ids: [instance_id])[0][0].instances[0].public_dns_name
puts "Instance public dns is : #{public_dns}"

wait_time=40
puts "Waiting for instance boot to finish"
wait_time.times { print "."; sleep(1)}
require 'aws-sdk'

puts "Initializing AWS conf"
Aws.config.update({
  region: 'us-west-2',
  credentials: Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
})

puts "Initiate a client in the Ireland region"
ec2 = Aws::EC2::Client.new(region: 'eu-west-1')

resp = ec2.describe_instances({
  filters: [
    {
      name: "tag:usage",
      values: ["etl"]
    }
  ]
})

if resp[0].count>0
  instances_to_stop = resp[0].map {|reservation| reservation.instances.map(&:instance_id)}.flatten
  
  puts "Stopping #{instances_to_stop.count} instances : #{instances_to_stop}"
  resp = ec2.terminate_instances({
    dry_run: true,
    instance_ids: instances_to_stop
  })
else
  puts "no m3.xlarge instances found to stop"
end
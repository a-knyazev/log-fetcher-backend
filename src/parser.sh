gawk -v date_format=$1 -v delta_time=$2 -v app=$3 -v action="$4" -v request_status=$5 '
BEGIN{
  action_regexp="^"action"$"
  now_time = systime()
  now_date = strftime(date_format, now_time)
  begin_time = now_time - delta_time
  count = 0
  count_fine = 0
  count_normal = 0
  count_bad = 0
}
{
  # example log entry
  # hh-favresumes PUT /resume/open/1282694867?empinfo=emp(1282694862),mng(1282694865) HTTP/1.1 0.106 1288686990.805 200
  match($0, /([^ ]+) (GET|POST|PUT|DELETE) ([^?]+)[^ ]+ HTTP\/[^ ]+ ([^ ]+) ([^ ]+) ([^ ]+)/, matches)

  log_entry_app = matches[1]
  if(log_entry_app != app)
    next

  log_time = matches[5]
  if(log_time <=begin_time)
    next

  url = matches[3]
  if(match(url, action_regexp) == 0)
    next

  status = matches[2]
  if(request_status && request_status != status)
    next

  count += 1;

  request_time = matches[4]
  if(request_time > 0.1)
    count_bad += 1
  else if(request_time > 0.05)
    count_normal += 1
  else
    count_fine += 1
}
END{
  if(count > 0)
  {
    print now_date","count","count_fine","count_normal","count_bad
  }
}'

#  whatsTheTime

This PowerShell function saves you time, by getting you the time when you need it!  Get any time in any timezone/city right now!

I wrote this to help myself, as I work across multiple global time zones and find the dateandtime.com type tools only slightly helpful.

Have you ever wanted to know what time it would be in a city when it's a specific time in another city, or just wanted to see a quick table of times between two cites?

Well this tool is for you, right in your command line.

Examples

```
PS > whatsTheTime -in Sydney -when 9am -in Orlando
[01:00 AM] (UTC+10:00) Eastern Australia Time (Sydney)
```

```
PS > whatsTheTime -in London -when 2pm -in LosAngeles
[10:00 PM] (UTC+00:00) United Kingdom Time
```

```
PS > whatsTheTime -showTableWith orlando -and sydney

ORL   UTC   SYD
---   ---   ---
12 AM 05 AM 04 PM
01 AM 06 AM 05 PM
02 AM 07 AM 06 PM
03 AM 08 AM 07 PM
04 AM 09 AM 08 PM
05 AM 10 AM 09 PM
06 AM 11 AM 10 PM
07 AM 12 PM 11 PM
08 AM 01 PM 12 AM
09 AM 02 PM 01 AM
10 AM 03 PM 02 AM
11 AM 04 PM 03 AM
12 PM 05 PM 04 AM
01 PM 06 PM 05 AM
02 PM 07 PM 06 AM
03 PM 08 PM 07 AM
04 PM 09 PM 08 AM
05 PM 10 PM 09 AM
06 PM 11 PM 10 AM
07 PM 12 AM 11 AM
08 PM 01 AM 12 PM
09 PM 02 AM 01 PM
10 PM 03 AM 02 PM
11 PM 04 AM 03 PM
```

## How do i get it?
1. Clone it `git clone git@github.com:adrwh/whatsTheTime.git`
2. CD into the repository directory `cd ./whatsTheTime`
3. Dot source it `. ./whatsTheTime.ps1`
4. Now you can call the function and begin using it `whatsTheTime <command>`

Put the function into your PS profile so you can run it anytime/always!


## Please feel free to contribute
Yeah, i'd love to have more experienced folk out there add to this or make comments to help me improve it.  Get it, make your changes and send a Pull Request!
Background
===

Recently, I started looking for a new [used] car. My search criteria were (in ballpark order of decreasing importance):
- ~$6-8k
- Excellent reliability/low maintenance
- No signs of wheel well rust
- Manual transmission
- Working A/C (a first for me!)
- Not red
- Alloy wheels (preference)
- Sunroof (preference)

All of these are self-identifying except reliability/maintenance. How does one find a true representation of this attribute? Here are a couple of existing data sources, and my concerns with them:
- [Consumer reports](http://consumerreports.org/cro/2013/04/best-worst-used-cars/index.htm): based on user surveys, hard to find an explanation of how they determine "reliabillity" (cost, frequency, other?).
- [JD Power & Associates](http://autos.jdpower.com/ratings/dependability.htm): based on survey results for cars 3 years old and newer (out of my price range), relies on owner memory/reporting

Then I stumbled on this gem: the [Long Term Quality Index](http://tradeinqualityindex.com/)

It's based on the mechanical inspections conducted by dealerships upon used vehicle trade-ins. There are *still* some limitations, but it's hard data, and the method is explained transparently:
- Issues are reported by only three categories (engine and transmission, with "powertrain" indicating an issue with both; this is calculated with 0's replaced for engine/tranny)
- Issues are reported simply by a 0 or 1 (no indication of more than one issue)
- No assessment of the cost of the issue is given
- The current site groups all years of a given model; were there "lemon years" vs. a vast improvement in quality for later years?
- Some of the visualizations were a bit confusing

The contact link provided an address at duke.edu, so I emailed the site author! I inquired about obtaining a sample data set to fiddle around with some alternative analyses/plots for them. The site authors turned out to be [Steven Lang](https://autos.yahoo.com/blogs/author/steven-lang/), a writer for the Yahoo! auto blog, and [Nick Lariviere](http://blog.wolfram.com/author/nick-lariviere/), and employee at Wolfram.

They were extremely generous and open to sharing some of their data, including sharing it with the TCRUG to see what our group could come up with! I hope that it proves an interesting and relevant data challenge for the group, and will pass along any insights and results back to them.

Files
===

I've obtained two files from Steve and Nick:
- `four-models.csv`: contains data on four different models of vehicle: Honda Accord, Mini Cooper, Chevy Cavalier, and Toyota Avalon. There is one row per vehicle, and columns are year, make, model, miles, and whether there was an engine or transmission issue.
- `distribution.csv`: this is the distribution of miles and engine/transmission/powertrain issues per year, for *all* cars contained in their whole data set.

Lastly, I've uploaded some starter code, which loads the above data files. The `distribution.csv` file was exported, presumably, from some sort of database and required some futzing to coerce it into a data frame.

Priming the pump
===

To get started with the data set, here are some questions that might help to get you started!
- How do the four models compare against each other and the all car distribution in terms of issues and miles?
- Are any of the models driven more miles per year, on average, than the others?
- Is there a correlation between issues found upon trade-in and the age of the vehicle?
- Do any of the vehicles feature particularly reliabile model years? Conversely, were there any "lemon years" for any of the models?
- Take a look at a make/model on the LTQI site (e.g. the [Honda page](http://tradeinqualityindex.com/reports/Honda.html)); how might you improve/modify the plots/graphics (assuming you had access to the necessary data) to make interpretation more transparent?
- Nick shared that the "Reliablity Score" shown is calculated using the following formula:

```
[(defect-free vehicles over 180k miles / total vehicles)
- x*(defective vehicles below 120k miles / total vehicles)
- x*(total defective vehicles / total vehicles)] / y
```

`x` and `y` are constants that have been calculated to provide a min/max of 0 and 100, with a mid-point of 50 for "average" vehicles (assuming I understood Nick correctly!). This rewards older, issue-free vehicles, and penalizes younger vehicles with issues. Would you adjust/change this method?
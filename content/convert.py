import markdownify

with open("ops.html") as file:
    data = file.read()

# convert html to markdown
md = markdownify.markdownify(data, heading_style="ATX")
  
print(md)

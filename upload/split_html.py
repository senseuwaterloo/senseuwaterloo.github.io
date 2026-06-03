import re
import os

html_file = 'index.html'
with open(html_file, 'r', encoding='utf-8') as f:
    content = f.read()

# Split the content into header, main sections, and footer
# The header ends with <main>
# The footer starts with </main>
header_match = re.search(r'(.*?<main>\n)', content, re.DOTALL)
footer_match = re.search(r'(    </main>\n\n    <!-- Footer -->.*?</html>)', content, re.DOTALL)

if not header_match or not footer_match:
    print("Could not find header or footer.")
    exit(1)

header = header_match.group(1)
footer = footer_match.group(1)

# Extract sections
# We will use regex to find each section/header
def extract_element(tag, tag_id, text):
    pattern = rf'(        <{tag} id="{tag_id}".*?>.*?</{tag}>\n)'
    match = re.search(pattern, text, re.DOTALL)
    return match.group(1) if match else ""

hero = extract_element('header', 'hero', content)
research = extract_element('section', 'research', content)
publications = extract_element('section', 'publications', content)
people = extract_element('section', 'people', content)
teaching = extract_element('section', 'teaching', content)
contact = extract_element('section', 'contact', content)

# Update the header navigation links
new_header = header.replace('href="#page-top"', 'href="index.html"')
new_header = new_header.replace('href="#research"', 'href="research.html"')
new_header = new_header.replace('href="#publications"', 'href="publications.html"')
new_header = new_header.replace('href="#people"', 'href="people.html"')
new_header = new_header.replace('href="#teaching"', 'href="teaching.html"')
new_header = new_header.replace('href="#contact"', 'href="contact.html"')

# We should also ensure the nav menu works correctly for index.html (the hero section is on index.html)
# Let's write the files
files = {
    'index.html': hero,
    'research.html': research,
    'publications.html': publications,
    'people.html': people,
    'teaching.html': teaching,
    'contact.html': contact
}

for filename, body_content in files.items():
    if not body_content:
        print(f"Warning: Empty content for {filename}")
        continue
    
    # We should add a generic spacing class or something?
    # No, CSS <section> has padding: 5rem 0. So it should look fine.
    # We can just inject the body_content between new_header and footer.
    page_content = new_header + body_content + footer
    with open(filename, 'w', encoding='utf-8') as f:
        f.write(page_content)
    print(f"Wrote {filename}")


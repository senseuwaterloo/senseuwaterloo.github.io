import urllib.request
import json

url = "https://api.github.com/orgs/senseuwaterloo/repos?per_page=100&type=public"
req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
try:
    with urllib.request.urlopen(req) as response:
        data = json.loads(response.read().decode())
        repos = []
        for repo in data:
            if not repo.get('archived'):
                repos.append({
                    'name': repo['name'],
                    'description': repo['description'],
                    'stars': repo['stargazers_count'],
                    'language': repo['language']
                })
        
        repos.sort(key=lambda x: x['stars'], reverse=True)
        for r in repos:
            print(f"- {r['name']} ({r['stars']} stars): {r['description']}")
except Exception as e:
    print("Error:", e)

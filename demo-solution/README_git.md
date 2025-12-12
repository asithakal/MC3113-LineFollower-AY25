# Git workflow

## Work on instructor demo
```bash
git checkout demo-instructor-complete
# ... make changes ...
git commit -m "Improve demo solution"
git push origin demo-instructor-complete
```

## Update student-facing materials
```bash
git checkout main
# ... make changes to templates, docs ...
git commit -m "Update ICD documentation"
git push origin main          # Update your private copy
git push student main         # Update student copy
```

Then you're ready! When Lecture 3 comes, you just share the link: `https://github.com/asithakal/MC3113-LineFollower-AY25.git`

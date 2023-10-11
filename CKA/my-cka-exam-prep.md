I was initially hesitant to undertake the Certified Kubernetes Administrator (CKA) exam due to negative experiences shared by others. Having faced performance-based exams, particularly Red Hat Certifications, I was wary of potential challenges with the PSI browser.  
  
# Preparation Recommendations:  
1. Comprehensive Course: Begin with a thorough course to establish a strong foundation. Many recommend Mumshad Mannambeth course on Udemy, but I found KodeKloud preferable due to additional labs and mock exams.  
  
2. Concept Understanding: After grasping the concepts, engage in hands-on labs and mock exams. I followed the order of Mumshad's CKA Certification Course on KodeKloud, including Lightning Labs and 4 mock exams. Multiple repetitions of mock exams were particularly helpful.  
  
3. Specialized Courses: Complete specialized courses like the JSON Path Test and Kubernetes Challenges on KodeKloud.  
4. Ultimate CKA Mock Exam: Conclude your preparation with the Ultimate Certified CKA Mock Exam on KodeKloud. Despite some bugs, it provides a comprehensive understanding of efficient documentation searches.  
  
## Pre-Exam Practices:  
- Perform "killersh" exercises three days before and the evening before the exam.  
- Take advantage of one session by resetting the environment and redo the exam to build muscle memory in typing imperative commands and declarative YAMLs.  
  
### Important Exam Day Points:  
- Be aware that the pre-check process starts 30 minutes before the scheduled time. ie If you have scheduled exam at 9:00 AM, the portal is allows you to check in at 8:30.  
- Use the Linux Foundation training portal to download the PSI browser and undergo ID scanning. This process is crucial and starts before exam start time.  
    
## Dealing with portal Issues:  
- On the day of exam make sure to check [Linux Foundation support portal](https://trainingstatus.linuxfoundation.org/) for incident status before your check in. Be prepared for worst case scenario (which happened on the day of my exam)  
- Bookmark the [JIRA](
https://jira.linuxfoundation.org/plugins/servlet/desk) ticket page  for creating tickets. Note that tickets are not handled over weekends.  
  
### PSI Browser Experience:  
- Upon exam launch, the PSI browser will download as an executable. If it doesn't load, keep hitting refresh.  
- The PSI browser experience is similar to the Red Hat exam using xfce desktop and Killer.sh exam simulator comes real close to real exam.  
  
### Exam Tips:  
- Open the terminal and Firefox immediately upon desktop load.    
- Zoom out Firefox and use system fonts with reduced font size in the terminal.    
- Consider adding useful aliases in .bashrc and .vimrc for efficiency and dont waste time overdoing it.    
- Disable security prompts in the terminal settings to copy YAML from Firefox.    
- To paste YAML without losing formatting in vim, escape out of insert mode and use CTRL+SHIFT+V.    
- There are links provided to documentation per question but Kubernetes documentation is readily available via Firefox browser.    
### Essential .bashrc/.vimrc entries :  
.bashrc:  
```  
alias k='kubectl'   
alias kgp='kubectl get pods -o wide'   
export dry='--dry-run=client -o yaml'   
alias krepl='kubectl replace --force -grace-period=0 -f'  
alias kd='kubectl describe'  
alias kr='kubectl run'  
```  
.vimrc (there were few items already there - which i didnt care for)  
```  
autocmd Filetype yaml ai et sts=2 ts=2 sw=2 colorcolumn=1,3,5,7,9,11,13 syntax on   
set nu   
set ci  
set cuc  
```  
### Exam Day Experience:  
- Expect questions that may be confusing due to language and lack of pictures.  
- Manage your time wisely; the exam duration is sufficient for completion and review.  
- Resist the temptation to end the exam early; thorough review is essential.  
- For Check-in process, less clutter in your room quicker the process is. It took me less than 10 mins for proctor to scan my room. I used a laptop tucked under my desk with one external 27" monitor + bluetooth Keyboard + bluetooth mouse + logitech Webcam attached to a super long usb cable.  
  
By following this preparation and exam strategy, I successfully navigated the CKA exam, overcoming potential challenges and ensuring a smooth experience.  
  
### Links:  
Certified Kubernetes Administrator (CKA) Training| KodeKloud  
Kubernetes Challenges - KodeKloud  
Ultimate Certified Kubernetes Administrator (CKA) Mock Exam Series - KodeKloud  
Component diagrams: https://shipit.dev/posts/kubernetes-overview-diagrams.html  
  
JsonPath:  
https://medium.com/@sovmirich/jsonpath-for-beginners-part-1-3-b8c973edf79e  
https://imarunrk.medium.com/certified-kubernetes-administrator-cka-tips-and-tricks-part-4-17407899ef1a  
Free JSON Path Test Course | KodeKloud  
The best tip i found to find the path in a json output is to use jq -c "paths(..)  
example:  
```  
kubectl get nodes -o json | jq -c 'paths( .. )' |grep <osImage>  
```  
  
### Discount Coupon for CKA exam:  
https://scriptcrunch.com/kubernetes-exam-guide/  
  
Additional scenarios that you can use KodeKloud Playground or killercoda portal to test out  
https://dev.to/subodev/50-questions-for-ckad-and-cka-exam-3bjm  

---
[Linkedin](https://www.linkedin.com/pulse/my-cka-exam-preparation-journey-prasana-raman%3FtrackingId=rzRQlP6rRgiHgI4Ore56cg%253D%253D/?trackingId=rzRQlP6rRgiHgI4Ore56cg%3D%3D)
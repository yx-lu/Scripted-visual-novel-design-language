#include<bits/stdc++.h>
#define exp EXP
using namespace std;
const int MAXLEN=1<<20,MAXPARA=1<<10;

int buflen;
char buf[MAXLEN+5];
char *pos;
string exp;
list<string> code;
map<string,int> para;

int image_multiple,textbox_transparency,font_size,button_dist,button_transparency;
pair<int,int> dpi,avatar_pos,textbox_pos,button_size,button_pos;
pair<int,pair<int,int> > textbox_rgb,button_rgb;
string paraval[MAXPARA];
//todo: Ĭ��ֵ 

int bnum,inum,snum,lnum;

int to_int(string s)
{
	int ans=0;
	for (int i=0;i<(int)s.length();i++)
	{
		if ((s[i]<'0')||(s[i]>'9')) {fprintf(stderr,"error while converting string to int.\n");exit(1);}
		ans=ans*10+s[i]-'0';
	}
	return ans;
}

void getexp()
{
	exp="";
	int in_str=0;
	while ((*pos!=';')||(in_str))
	{
		if (*pos=='\0') {fprintf(stderr,"error while reading expression.\n");exit(1);}
		exp+=*pos;
		if (in_str==2) in_str=1;
		else if (*pos=='\"') in_str^=1;
		else if (*pos=='\\') in_str+=(in_str==1);
		pos++;
	}
	pos++;
}

void read_header()
{
	if ((*pos!='`')||(*(pos+1)!='`')||(*(pos+2)!='`')) {fprintf(stderr,"error while reading header.\n");exit(1);}
	pos+=3;
	while (*pos!='`')
	{
		getexp();
		string::size_type w=exp.find('=');if (w==string::npos) {fprintf(stderr,"error while reading header.\n");exit(1);}
		string item=exp.substr(0,w),value=exp.substr(w+1,exp.length()-(w+1));
		if (item=="dpi")
		{
			w=value.find(',');if (w==string::npos) {fprintf(stderr,"error while reading header.\n");exit(1);}
			dpi=make_pair(to_int(value.substr(0,w)),to_int(value.substr(w+1,value.length()-(w+1))));
		}
		else if (item=="avatar_pos")
		{
			w=value.find(',');if (w==string::npos) {fprintf(stderr,"error while reading header.\n");exit(1);}
			avatar_pos=make_pair(to_int(value.substr(0,w)),to_int(value.substr(w+1,value.length()-(w+1))));
		}
		else if (item=="image_multiple")
		{
			image_multiple=to_int(value);
		}
		else if (item=="textbox_pos")
		{
			w=value.find(',');if (w==string::npos) {fprintf(stderr,"error while reading header.\n");exit(1);}
			textbox_pos=make_pair(to_int(value.substr(0,w)),to_int(value.substr(w+1,value.length()-(w+1))));
		}
		else if (item=="textbox_transparency")
		{
			textbox_transparency=to_int(value);
		}
		else if (item=="textbox_rgb")
		{
			w=value.find(',');if (w==string::npos) {fprintf(stderr,"error while reading header.\n");exit(1);}
			string r=value.substr(0,w);value=value.substr(w+1,value.length()-(w+1));
			w=value.find(',');if (w==string::npos) {fprintf(stderr,"error while reading header.\n");exit(1);}
			textbox_rgb=make_pair(to_int(r),make_pair(to_int(value.substr(0,w)),to_int(value.substr(w+1,value.length()-(w+1)))));
		}
		else if (item=="font_size")
		{
			font_size=to_int(value);
		}
		else if (item=="button_size")
		{
			w=value.find(',');if (w==string::npos) {fprintf(stderr,"error while reading header.\n");exit(1);}
			button_size=make_pair(to_int(value.substr(0,w)),to_int(value.substr(w+1,value.length()-(w+1))));
		}
		else if (item=="button_pos")
		{
			w=value.find(',');if (w==string::npos) {fprintf(stderr,"error while reading header.\n");exit(1);}
			button_pos=make_pair(to_int(value.substr(0,w)),to_int(value.substr(w+1,value.length()-(w+1))));
		}
		else if (item=="button_dist")
		{
			button_dist=to_int(value);
		}
		else if (item=="button_transparency")
		{
			button_transparency=to_int(value);
		}
		else if (item=="button_rgb")
		{
			w=value.find(',');if (w==string::npos) {fprintf(stderr,"error while reading header.\n");exit(1);}
			string r=value.substr(0,w);value=value.substr(w+1,value.length()-(w+1));
			w=value.find(',');if (w==string::npos) {fprintf(stderr,"error while reading header.\n");exit(1);}
			button_rgb=make_pair(to_int(r),make_pair(to_int(value.substr(0,w)),to_int(value.substr(w+1,value.length()-(w+1)))));
		}
		else if (para.count(item))
		{
			paraval[para[item]]=value;
		}
		else {fprintf(stderr,"unknown header.\n");exit(1);}
	}
	if ((*pos!='`')||(*(pos+1)!='`')||(*(pos+2)!='`')) {fprintf(stderr,"error while reading header.\n");exit(1);}
	pos+=3;
}

void read_precondition()
{
	if ((*pos!='`')||(*(pos+1)!='`')||(*(pos+2)!='`')) {fprintf(stderr,"error while reading header.\n");exit(1);}
	pos+=3;
	while (*pos!='`')
	{
		getexp();
		string::size_type w=exp.find('=');if (w==string::npos) {fprintf(stderr,"error while reading precondition.\n");exit(1);}
		string item=exp.substr(0,w),value=exp.substr(w+1,exp.length()-(w+1));
		char ch=item[0];item.erase(0,1);
		if (ch=='b')
		{
			bnum=max(bnum,to_int(item));
			if ((value!="true")&&(value!="false")) {fprintf(stderr,"assigning error while reading precondition.\n");exit(1);}
			code.push_back("set "+item+" "+((value=="true")?"1":"0"));
		}
		else if (ch=='i')
		{
			inum=max(inum,to_int(item));
			to_int(value);//it could be as large as unsigned long long but to_int returns iff value is a number
			code.push_back("mov "+item+" "+value);
		}
		else if (ch=='s')
		{
			snum=max(snum,to_int(item));
			if ((value[0]!='\"')||(value[value.length()-1]!='\"')) {fprintf(stderr,"assigning error while reading precondition.\n");exit(1);}
			code.push_back("assign "+item+" "+value);
		}
		else {fprintf(stderr,"unknown precondition.\n");exit(1);}
	}
	if ((*pos!='`')||(*(pos+1)!='`')||(*(pos+2)!='`')) {fprintf(stderr,"error while reading header.\n");exit(1);}
	pos+=3;
}

struct node
{
	string op;
	node *s1,*s2,*s3,*s4,*s5,*s6;
	list <string> res;
	int ret,ret2,ret3;
	node(string _op)
	{
		op=_op;
		s1=s2=s3=s4=s5=s6=NULL;
		res.clear();
		ret=ret2=ret3=0;
	}
	node*& sons(int k)
	{
		if (k==1) return s1;
		if (k==2) return s2;
		if (k==3) return s3;
		if (k==4) return s4;
		if (k==5) return s5;
		if (k==6) return s6;
		fprintf(stderr,"no such son.\n");exit(1);
	}
};
node *root;
node* build_syntaxtree(int l,int r)
{
	if (exp[r]!=')') {fprintf(stderr,"error while reading syntaxtree.\n");exit(1);}
	int mid=l;while ((mid<r)&&(exp[mid]!='(')) mid++;
	if (mid==r) {fprintf(stderr,"error while reading syntaxtree.\n");exit(1);}
	node *now=new node(exp.substr(l,mid-l));
	l=mid+1;
	for (int ns=1;;ns++)
	{
		mid=l;int in_str=0;
		while (((exp[mid]!=',')||(in_str))&&(mid!=r))
		{
			if (in_str==2) in_str=1;
			else if (*pos=='\"') in_str^=1;
			else if (*pos=='\\') in_str+=(in_str==1);
			mid++;
		}
		now->sons(ns)=build_syntaxtree(l,mid-1);
		l=mid+1;
	}
	return now;
}

void read_syntaxtree()
{
	getexp();
	root=build_syntaxtree(0,exp.length()-1);
}

void addpara(string s)
{
	para[s]=para.size();
}

void init(FILE* input)
{
	fgets(buf,MAXLEN,input);buflen=strlen(buf);
	int j=0;
	for (int i=0;i<buflen;i++) if ((buf[i]!=' ')&&(buf[i]!='\r')&&(buf[i]!='\n')) buf[j++]=buf[i];
	buf[j]='\0';buflen=j;
	
	addpara("left");addpara("right");addpara("top");addpara("bottom");
	addpara("topleft");addpara("bottomleft");addpara("topright");addpara("bottomright");
	addpara("medium");
	addpara("custom1");addpara("custom2");addpara("custom3");addpara("custom4");
	
	read_header();
	read_precondition();
	read_syntaxtree();
	if (*pos!='\0') {fprintf(stderr,"unknown end of file.\n");exit(1);}
}

void lkback(list<string> &p,list<string> &q)
{
	p.splice(p.end(),q);
}
void lkback(list<string> &p,list<string> &q,list<string> &r)
{
	p.splice(p.end(),q);
	p.splice(p.end(),r);
}
void lkback(list<string> &p,list<string> &q,list<string> &r,list<string> &s)
{
	p.splice(p.end(),q);
	p.splice(p.end(),r);
	p.splice(p.end(),s);
}

/*struct node
{
	string op;
	node *s1,*s2,*s3,*s4,*s5,*s6;
	list <string> res;
	int ret,ret2,ret3;
	node(string _op)
	node*& sons(int k)
};*/
void generate_intermediate_code(node *now=root)
{
	if (now==NULL) return;
	generate_intermediate_code(now->s1);generate_intermediate_code(now->s2);generate_intermediate_code(now->s3);
	generate_intermediate_code(now->s4);generate_intermediate_code(now->s5);generate_intermediate_code(now->s6);
	string op=now->op;
	//---var
	if (((op[0]=='b')||(op[0]=='i')||(op[0]=='s'))&&(op[1]>='0')&&(op[1]<='9'))
	{
		now->ret=to_int(op.substr(1,op.length()-1));
	}
	//---parameter
	else if (para.count(op))
	{
		now->ret=para[op];
	}
	//---bool
	else if ((op=="true")||(op=="false"))
	{
		now->ret=++bnum;
		now->res.push_back("set "+to_string(bnum)+((op=="true")?" 1":" 0"));
	}
	else if (op=="not")
	{
		lkback(now->res,now->s1->res);
		now->ret=++bnum;
		now->res.push_back(op+" "+to_string(bnum)+" "+to_string(now->s1->ret));
	}
	else if ((op=="and")||(op=="or")||(op=="xor"))
	{
		lkback(now->res,now->s1->res,now->s2->res);
		now->ret=++bnum;
		now->res.push_back(op+" "+to_string(bnum)+" "+to_string(now->s1->ret)+" "+to_string(now->s2->ret));
	}
	//---int
	else if ((op[0]>='0')&&(op[0]<='9'))
	{
		to_int(op);
		now->ret=++inum;
		now->res.push_back("mov "+to_string(inum)+" "+op);
	}
	else if ((op=="add")||(op=="sub")||(op=="mul")||(op=="div"))
	{
		lkback(now->res,now->s1->res,now->s2->res);
		now->ret=++inum;
		now->res.push_back(op+" "+to_string(inum)+" "+to_string(now->s1->ret)+" "+to_string(now->s2->ret));
	}
	else if ((op=="less")||(op=="greater")||(op=="leq")||(op=="geq")||(op=="eq")||(op=="neq"))
	{
		lkback(now->res,now->s1->res,now->s2->res);
		now->ret=++bnum;
		now->res.push_back(op+" "+to_string(bnum)+" "+to_string(now->s1->ret)+" "+to_string(now->s2->ret));
	}
	//---string
	else if ((op[0]=='\"')&&(op[op.length()-1]=='\"'))
	{
		now->ret=++snum;
		now->res.push_back("assign "+to_string(snum)+" "+op);
	}
	else if (op=="cancat")
	{
		lkback(now->res,now->s1->res,now->s2->res);
		now->ret=++snum;
		now->res.push_back(op+" "+to_string(snum)+" "+to_string(now->s1->ret)+" "+to_string(now->s2->ret));
	}
	else if ((op=="same")||(op=="diff"))
	{
		lkback(now->res,now->s1->res,now->s2->res);
		now->ret=++bnum;
		now->res.push_back(op+" "+to_string(snum)+" "+to_string(now->s1->ret)+" "+to_string(now->s2->ret));
	}
	//---image&music
	else if ((op=="image")||(op=="music"))
	{
		lkback(now->res,now->s1->res);
		now->ret=now->s1->ret;
	}
	else if (op=="silent")
	{
		now->ret=0;
	}
	//---action
	else if ((op=="halt")||(op=="nop"))
	{
		now->res.push_back(op);
	}
	else if ((op=="set")||(op=="mov")||(op=="assign"))
	{
		lkback(now->res,now->s1->res,now->s2->res);
		now->res.push_back(op+" "+to_string(now->s1->ret)+" "+to_string(now->s2->ret));
	}
	else if (op=="show")
	{
		lkback(now->res,now->s1->res);
		string p=paraval[(now->s2==NULL)?para["medium"]:now->s2->ret];
		if (p.find(',')==string::npos) {fprintf(stderr,"error while analysing parameters.\n");exit(1);}
		p[p.find(',')]=' ';
		now->res.push_back(op+" image "+to_string(now->s1->ret)+" "+p);
	}
	else if (op=="hide")
	{
		lkback(now->res,now->s1->res);
		now->res.push_back(op+" "+to_string(now->s1->ret));
	}
	else if (op=="play")
	{
		lkback(now->res,now->s1->res);
		now->res.push_back("show music "+to_string(now->s1->ret));
	}
	else if (op=="say")
	{
		lkback(now->res,now->s1->res,now->s2->res);
		if (now->s3!=NULL) lkback(now->res,now->s3->res);
		now->res.push_back("show image "+to_string(now->s1->ret)+" "+to_string(avatar_pos.first)+" "+to_string(avatar_pos.second));
		now->res.push_back("show textbox "+to_string(now->s1->ret2)+" "+to_string(now->s2->ret));
		now->res.push_back("pause");
		now->res.push_back("hide "+to_string(now->s1->ret));
	}
	else if (op=="cont")
	{
		lkback(now->res,now->s1->res,now->s2->res);
	}
	else if (op=="if")
	{
		lkback(now->res,now->s1->res);
		now->res.push_back("jne "+to_string(now->s1->ret)+" "+to_string(++lnum));
		lkback(now->res,now->s3->res);
		now->res.push_back("jmp "+to_string(++lnum));
		now->res.push_back("label "+to_string(lnum-1));
		lkback(now->res,now->s2->res);
		now->res.push_back("label "+to_string(lnum));
	}
	//---character
	else if (op=="character")
	{
		lkback(now->res,now->s1->res,now->s2->res);
		now->ret=now->s2->ret;
		now->ret2=now->s1->ret;
	}
	else if (op=="nobody")
	{
		now->ret=0;
		now->ret2=0;
	}
	//---scene
	else if (op=="scene")
	{
		lkback(now->res,now->s1->res,now->s2->res);
		now->res.push_back("show image "+to_string(now->s1->ret));
		now->res.push_back("show music "+to_string(now->s2->ret));
		lkback(now->res,now->s3->res);
	}
	else if (op=="blank")
	{
		//do nothing
	}
	//---menu
	else if (op=="arrow")
	{
		//do nothing("menu" will do)
	}
	else if (op=="menu")
	{
		int snum=(int)(now->s1!=NULL)+(now->s6!=NULL)+(now->s6!=NULL)+(now->s6!=NULL)+(now->s6!=NULL)+(now->s6!=NULL);
		int p=button_pos.second-button_dist*snum/2,ln=lnum;
		for (int i=1;i<=6;i++) if (now->sons(i)!=NULL)
		{
			lnum++;
			now->res.push_back("show button "+to_string(now->sons(i)->s1->ret)+" "+to_string(button_pos.first)+" "+to_string(p)+" "+to_string(lnum));
			p+=button_dist;
		}
		now->res.push_back("pause");
		lnum++;
		for (int i=1;i<=6;i++) if (now->sons(i)!=NULL)
		{
			now->res.push_back("label "+to_string(++ln));
			lkback(now->res,now->sons(i)->s2->res);
			now->res.push_back("jmp "+to_string(lnum));
		}
		now->res.push_back("label "+to_string(lnum));
	}
	//---
	else if (op=="contframe")
	{
		lkback(now->res,now->s1->res,now->s2->res);
	}
	else if (op=="ifframe")
	{
		lkback(now->res,now->s1->res);
		now->res.push_back("jne "+to_string(now->s1->ret)+" "+to_string(++lnum));
		lkback(now->res,now->s3->res);
		now->res.push_back("jmp "+to_string(++lnum));
		now->res.push_back("label "+to_string(lnum-1));
		lkback(now->res,now->s2->res);
		now->res.push_back("label "+to_string(lnum));
	}
	else {fprintf(stderr,"unknown syntax tree node.\n");exit(1);}
}

void post_process(FILE *output)
{
	fprintf(output,"```\n");
	fprintf(output,"%d %d\n",dpi.first,dpi.second);
	fprintf(output,"%d\n",image_multiple);
	fprintf(output,"%d %d %d %d %d %d\n",textbox_pos.first,textbox_pos.second,
		textbox_transparency,textbox_rgb.first,textbox_rgb.second.first,textbox_rgb.second.second);
	fprintf(output,"%d\n",font_size);
	fprintf(output,"%d %d %d %d %d %d\n",button_size.first,button_size.second,
		button_transparency,button_rgb.first,button_rgb.second.first,button_rgb.second.second);
	fprintf(output,"```\n");
	lkback(code,root->res);
	for (list<string>::iterator it=code.begin();it!=code.end();it++) fprintf(output,"%s\n",it->c_str());
}
int main()
{
	FILE *input=fopen("syntax_tree.txt","r");
	FILE *output=fopen("intermediate_code.txt","w");
	init(input);
	generate_intermediate_code();
	post_process(output);
}

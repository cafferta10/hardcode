int c,i,x,y,z,w=1280,h=720,u;float f,r;void settings(){size(w,h);}void draw(){u+=f/h;f%=h;f+=sq(sin(r+=.01));for(i=1;i<w*h;i++)a();}
void a(){x=i/h;y=i%h;z=int(f*h)+abs(x-w/2);c=(i*z*y%h)/16;if(u<2)c=z%(w/8)-z+y;if(u<1)c=z%(y+1);set(x,y,color(c));}
// Documentation available at https://donadigo.com/tminterface/plugins/api

vec3 pos;
vec3 origin;
vec3 upper;
vec2 size;
vec2 oldgrid;
vec2 curgrid;
uint numckpt;
int gdnumber;
int finlocx;
int finlocy;
int oldgdnumber;
InputType inpt;
InputType oldinpt;
float timer;
float approx;
int Arrayhaszero;
int Spawngdnumber;
float averagereward;
int drgdnumber;
float Downreward;
float Upreward;
float Leftreward;
float Rightreward;
float firstcalc;
float secondcalc;
uint speed;
int noreward;
int length;
int drgdnumberfeed;
float yaw;
float pitch;
float roll;
int pastloc;
int pastlocdr;
int spawnpastloc;
int lowspeed;
vec2 SpawnGrid;
float foi; //factor of importance

class Qdirection
{
	array<float> reward;
};

class Qcell
{
	array<Qdirection> dir (4);
};

array<Qcell>@ Qtable;

void logrewards(int gd, int loc, string msg)
{
	log(msg + ": rewards for grid number " + gd + " for past location " + loc);
	log ("down:  "+Qtable[gd].dir[loc].reward[0]);
	log ("up:    "+Qtable[gd].dir[loc].reward[1]);
	log ("left:  "+Qtable[gd].dir[loc].reward[2]);
	log ("right: "+Qtable[gd].dir[loc].reward[3]);
}

vec2 getgridfrompos(vec3 pos)
{
    vec2 curgrid;

    curgrid.x=(pos.x-origin.x)/size.x;
    curgrid.y=(pos.z-origin.z)/size.y;

    int x=curgrid.x;
    int y=curgrid.y;
    x=x+1;
    y=y+1;

    vec2 ret;
    ret.x=x;
    ret.y=y;
    return ret;
}

vec2 getgridfromSpawnpos(vec3 SpawnLoc)
{
	//log ("probe 4.1");
    vec2 SpawnGrid;

    SpawnGrid.x=(SpawnLoc.x-origin.x)/size.x;
    SpawnGrid.y=(SpawnLoc.z-origin.z)/size.y;

	//log ("spawngrid "+SpawnGrid.x+","+SpawnGrid.y);

    int x=SpawnGrid.x;
    int y=SpawnGrid.y;
    x=x+1;
    y=y+1;

	//log ("spawngrid after "+x+","+y);

    vec2 retrn;
    retrn.x=x;
    retrn.y=y;
    return retrn;
}

float deeperrewardstimer ()
{
	float firstpos = Qtable[drgdnumber].dir[pastloc].reward[0];
	float secondpos = Qtable[drgdnumber].dir[pastloc].reward[1];
	float thirdpos = Qtable[drgdnumber].dir[pastloc].reward[2];
	float fourthpos = Qtable[drgdnumber].dir[pastloc].reward[3];
	averagereward = (firstpos+secondpos+thirdpos+fourthpos)/4;
	
	return averagereward;
}

int directioncalc ()
{
	int ret;
	if ((yaw >= 2.3565) || (yaw <= -2.3565))
	{
		ret = 1;
	}
	else if ((yaw >= -2.3565) && (yaw <= -0.7855))
	{
		ret = 2;
	}
	else if ((yaw >= -0.7855) && (yaw <= 0.7855))
	{
		ret = 0;
	}
	else if ((yaw >= 0.7855) && (yaw <= 2.3565))
	{
		ret = 3;
	}
	else
	{
		ret = 10;
	}
	return ret;
}

int drgdnumbercalc ()
{
	int ret;
	if (directioncalc () == drgdnumberfeed)
	{
		if (directioncalc () >= 2)
		{
			ret = 1;
		}
		else
		{
			ret = -1;
		}
	}
	else
	{
		if ((directioncalc () + drgdnumberfeed == 1))
		{
			ret = 1;
		}
		else if ((directioncalc () + drgdnumberfeed == 2) || (directioncalc () + drgdnumberfeed == 4))
		{
			ret = length;
		}
		else if (directioncalc () + drgdnumberfeed == 3)
		{
			ret = -length;
		}
		else if ((directioncalc () + drgdnumberfeed == 5))
		{
			ret = -1;
		}
	}
	return ret;
}

bool onedgeofgrid ()
{
	bool ret;
	
	if ((drgdnumber <= 0) || (drgdnumber >= length**2))
	{
		//fail case 1 left or right of grid
		ret = true;
	}
	else if ((gdnumber % length == 0) || (gdnumber % length == 1))
	{
		//fail case 2 top or bottom of grid
		ret = true;
	}
	else
	{
		ret = false;
	}
	return ret;
}

int pastgridcalc ()
{
	int ret;
	
	if (curgrid.x == oldgrid.x)
	{
		if (curgrid.y > oldgrid.y)
		{
			ret = 1;
		}
		else
		{
			ret = 0;
		}
	}
	else
	{
		if (curgrid.x > oldgrid.x)
		{
			ret = 2;
		}
		else
		{
			ret = 3;
		}
	}
	return ret;
}


int pastloccalc ()
{
	int ret;
	int pastcalc = pastgridcalc();
	int dircalc = directioncalc();
	if (dircalc == pastcalc)
	{
		ret = dircalc;
	}
	else
	{
		switch (dircalc)
		{
			case 0:
				ret = 1;
				break;
			case 1:
				ret = 0;
				break;
			case 2:
				ret = 3;
				break;
			case 3:
				ret = 2;
				break;
			default:
				log("broken");
				break;
		}
	}
	return ret;
}

int pastlocdrcalc ()
{
	int ret;
	if (directioncalc () == 0)
	{
		ret = drgdnumberfeed;
	}
	else if (directioncalc () == 1)
	{
		if ((drgdnumberfeed == 1) || (drgdnumberfeed == 3))
		{
			ret = drgdnumberfeed-1;
		}
		else
		{
			ret = drgdnumberfeed+1;
		}
	}
	if (directioncalc () + drgdnumberfeed == 2)
	{
		ret = 2;
	}
	else if (directioncalc () + drgdnumberfeed == 3)
	{
		ret = 3;
	}
	else if (directioncalc () + drgdnumberfeed == 5)
	{
		ret = 0;
	}
	else if (directioncalc () + drgdnumberfeed == 4)
	{
		if (directioncalc () == 2)
		{
			ret = 1;
		}
		else
		{
			ret = 2;
		}
	}
	return ret;
}

bool movementcheck (int cgx,int cgy,int ogx,int ogy)
{
	bool ret;
	log ("curgrid.x, oldgrid.x, curgrid.y, oldgrid.y "+cgx+","+ogx+","+cgy+","+ogy);
	
	if ((cgx - ogx < -1) || (cgx - ogx > 1))
	{
		log ("probe 3.1");
		ret = false;
	}
	else if ((cgy - ogy < -1) || (cgy - ogy > 1))
	{
		log ("probe 3.2");
		ret = false;
	}
	else
	{
		ret = true;
	}
	
	return ret;
}

int wheelsongrass (SimulationManager@ simManager)
{
	int ret;

	// check wheels
	int ongrass1 = 0;
	int ongrass2 = 0;
	int ongrass3 = 0;
	int ongrass4 = 0;
	
	SimulationWheels@ wheels = simManager.get_Wheels();
	TM::SceneVehicleCar::SimulationWheel@ FL = wheels.get_FrontLeft();
	if (FL.RTState.ContactMaterialId ==  TM::PlugSurfaceMaterialId::Grass) { ongrass1 = 1; }

/*	
	// For some reasno FR and BL do not show the right material.
	// Only check FL.  This is good enough to give a bad reward when it goes off the trackAsMenu
	// but doesn't give a bad reward to up input after going down on the starting block.

	TM::SceneVehicleCar::SimulationWheel@ FR = wheels.get_FrontRight();
	if (FR.RTState.ContactMaterialId ==  TM::PlugSurfaceMaterialId::Grass) { ongrass2 = 1; }
	
	TM::SceneVehicleCar::SimulationWheel@ BL = wheels.get_BackLeft();
	if (BL.RTState.ContactMaterialId ==  TM::PlugSurfaceMaterialId::Grass) { ongrass3 = 1; }
	
	TM::SceneVehicleCar::SimulationWheel@ BR = wheels.get_BackRight();
	if (BR.RTState.ContactMaterialId ==  TM::PlugSurfaceMaterialId::Grass) { ongrass4 = 1; }
	
	log ("1st"+ongrass1+"2nd"+ongrass2+"3rd"+ongrass3+"4th"+ongrass4);
	log ("FL "+FL.RTState.ContactMaterialId+" FR "+FR.RTState.ContactMaterialId+" BL "+BL.RTState.ContactMaterialId+" BR "+BR.RTState.ContactMaterialId);
	
`	if ((ongrass1 == 1) && (ongrass2 == 1) && (ongrass3 == 1) && (ongrass4 == 1))
*/

	if (ongrass1 == 1)
	{
		ret = 1;
	}
	else
	{
		ret = 0;
	}
	
	return ret;
}

void inputnewreward (int gd, int loc, float reward, InputType inpt, string msg)
{
	log (msg+":gridnumber "+gd+" reward "+reward+" inpt "+inpt);
	int input;
	
	if (inpt == InputType::Down) { input = 0;} else if (inpt == InputType::Up) { input = 1;}
	else if (inpt == InputType::Left) { input = 2;} else if (inpt == InputType::Right) { input = 3;}
	
	Qtable[gd].dir[loc].reward[input] = reward;
}


void OnRunStep(SimulationManager@ simManager)
{
    vec3 pos = simManager.Dyna.CurrentState.Location.Position;
	simManager.Dyna.CurrentState.Location.Rotation.GetYawPitchRoll(yaw,pitch,roll);
    vec2 curgrid = getgridfrompos(pos);
	float oldhyp = 0;
	float newhyp = 0;
	float rewardvalue = 0;
    int cgx=curgrid.x;
    int cgy=curgrid.y;
	int ogx=oldgrid.x;
	int ogy=oldgrid.y;
	//log ("curcheckpoint "+simManager.PlayerInfo.CurCheckpointCount);

	if (simManager.PlayerInfo.CurCheckpointCount == 0)
	{
		vec3 SpawnLoc = simManager.PlayerInfo.VehicleSpawnLoc.Position;
		SpawnGrid = getgridfromSpawnpos (SpawnLoc);

		Spawngdnumber = SpawnGrid.y + (SpawnGrid.x-1)*length;
	}
	//log ("spawn loc x:"+SpawnGrid.x+"spawn loc y:"+SpawnGrid.y);		
	speed = simManager.PlayerInfo.DisplaySpeed;
	
	//numbering grid
	if (curgrid.x==0 && curgrid.y==0)
	{
		gdnumber = 0;
	}
	else
	{
		gdnumber = curgrid.y + (curgrid.x-1)*length;
	
		//change *7 to how wide the grid is going to be. ie if it's the entire building area with grid size 30 it will be *34
	}
    //log ("spawn gd number "+Spawngdnumber);
	//log ("grid number "+gdnumber);
    //log("grid position x="+cgx+" y="+cgy);
    //log("real position x="+pos.x+" y="+pos.z);
	
    if (oldgrid.x==0 && oldgrid.y==0)
    {
		 log ("skipping calculation");

		 // # of checkpoint
		 TM::PlayerInfo@ PI = simManager.get_PlayerInfo();
		 array<int> ckpt = PI.get_CheckpointStates();
		 numckpt = ckpt.get_Length();
		 log("number of checkpoints "+numckpt);
		 
	 	// initialize Qtable values
		for (uint num=0; num<Qtable.get_Length(); num=num+1)
		{
			for (uint num2=0; num2<Qtable[num].dir.get_Length(); num2++)
			{
				Qtable[num].dir[num2].reward={-5,0,0,0,-1000};
			}
		}
		
		simManager.PlayerInfo.VehicleSpawnLoc.Rotation.GetYawPitchRoll(yaw, pitch, roll);
		
		spawnpastloc = directioncalc ();
		if ((spawnpastloc == 1) || (spawnpastloc == 3))
		{
			spawnpastloc = spawnpastloc-1;
		}
		else
		{
			spawnpastloc = spawnpastloc+1;
		}
    }
    else
    {	
		if ((curgrid.x == SpawnGrid.x) && (curgrid.y == SpawnGrid.y))
		{
			noreward = 0;
		}
	
		if ((curgrid.x != oldgrid.x) || (curgrid.y != oldgrid.y))
		{
			//log ("movementcheck "+movementcheck (cgx, cgy, ogx, ogy));
			timer = 5;
			log("probe 1");
			if (noreward == 1)
			{
				log ("skipping reward");
				noreward = 0;
				//instead of giving up again see if idle timer takes care of it
				//simManager.GiveUp();
			}
			else if (movementcheck (cgx, cgy, ogx, ogy) == true)
			{
				log("movement detected, was in " + oldgdnumber + " now in " + gdnumber);
				
				simManager.SetInputState(InputType::Down, 0);
				simManager.SetInputState(InputType::Up, 0);
				simManager.SetInputState(InputType::Left, 0);
				simManager.SetInputState(InputType::Right, 0);
				
				//log ("speed "+speed);
				if ((speed <= 25) && (simManager.PlayerInfo.RaceTime >= 100))
				{
					lowspeed = 1;
				}
				
				// log old rewards for oldgdnumber here
				logrewards(oldgdnumber, pastloc, "before speed");

				if (lowspeed == 1)
				{
					log("probe 1.1");
					if (inpt == InputType::Down)
					{
					 Qtable[oldgdnumber].dir[pastloc].reward[0] = -2;
					}
					else if (inpt == InputType::Up)
					{
					 Qtable[oldgdnumber].dir[pastloc].reward[1] = 1; // was -3
					}
					else if (inpt == InputType::Left)
					{
					 Qtable[oldgdnumber].dir[pastloc].reward[2] = -2;
					}
					else if (inpt == InputType::Right)
					{
					 Qtable[oldgdnumber].dir[pastloc].reward[3] = -2;
					}
				}
				else
				{
					rewardvalue = 0;
					//reward calc
				
					oldhyp = Math::Sqrt((finlocx-ogx)**2+(finlocy-ogy)**2);
					newhyp = Math::Sqrt((finlocx-cgx)**2+(finlocy-cgy)**2);
					
					rewardvalue=oldhyp-newhyp;
					//log ("reward value "+rewardvalue);
					//log ("oldhyp "+oldhyp+" newhyp "+newhyp);
					
					//log ("oldgdnumber "+oldgdnumber);
					log ("oldinpt "+oldinpt);
					
					//Qtable[gdnumber].reward = { 47, 53, 12, 11 };
					//inputing reward for previous movement
					if (oldinpt == InputType::Down)
					{
					 Qtable[oldgdnumber].dir[pastloc].reward[0] = rewardvalue;
					}
					else if (oldinpt == InputType::Up)
					{
					 Qtable[oldgdnumber].dir[pastloc].reward[1] = rewardvalue;
					}
					else if (oldinpt == InputType::Left)
					{
					 Qtable[oldgdnumber].dir[pastloc].reward[2] = rewardvalue;
					}
					else if (oldinpt == InputType::Right)
					{
					 Qtable[oldgdnumber].dir[pastloc].reward[3] = rewardvalue;
					}
				}
				
				// log new rewards for oldgdnumber here
				logrewards(oldgdnumber, pastloc, "after speed");

				pastloc = pastloccalc ();
				log ("pastloc "+pastloc);

				if (lowspeed == 0)
				{

					// log rewards for gdnumber here (since they are used to determine the choice of input)
					logrewards(gdnumber, pastloc, "input");
					
					//If there is a input that is unexplored, take it
					for (int i = 0; i < 4; i= i+1)
					{
						if (Qtable[gdnumber].dir[pastloc].reward[i] == 0)
						{
						Arrayhaszero = i;
						break;
						}
						Arrayhaszero = 4;
					}
					
					//log ("Arrayhaszero "+Arrayhaszero);
					
					if (Qtable[gdnumber].dir[pastloc].reward[Arrayhaszero] == 0)
					{
						if (Arrayhaszero==0)
						{
							inpt = InputType::Down;
						}
						else if (Arrayhaszero==1)
						{
							inpt = InputType::Up;
						}
						else if (Arrayhaszero==2)
						{
							inpt = InputType::Left;
						}
						else if (Arrayhaszero==3)
						{
							inpt = InputType::Right;
						}
					}
					//if Arrayhaszero is 4 (no zero) then do this. This will be normal move calculation. 
					else
					{
						//adjusted down reward
						drgdnumberfeed = 0;
						drgdnumber = gdnumber+drgdnumbercalc ();
						
						pastlocdr = pastlocdrcalc ();
						
						if (onedgeofgrid () == true)
						{
							Downreward = -100;
						}
						else
						{
							averagereward = deeperrewardstimer();
							Downreward = Qtable[gdnumber].dir[pastloc].reward[0]+foi*averagereward;
						}
						
						//adjusted up reward
						if (Qtable[gdnumber].dir[pastloc].reward[1] == 1)
						{
							Upreward = 10;
						}
						else
						{
							drgdnumberfeed = 1;
							drgdnumber = gdnumber+drgdnumbercalc ();
							
							pastlocdr = pastlocdrcalc ();
							
							if (onedgeofgrid () == true)
							{
								Upreward = -100;
							}
							else
							{
								averagereward = deeperrewardstimer();
								Upreward = Qtable[gdnumber].dir[pastloc].reward[1]+foi*averagereward;
							}
						}
						
						//adjusted left reward
						drgdnumberfeed = 2;
						drgdnumber = gdnumber+drgdnumbercalc ();
						
						pastlocdr = pastlocdrcalc ();
						
						if (onedgeofgrid () == true)
						{
							Leftreward = -100;
						}
						else
						{
						averagereward = deeperrewardstimer();
						Leftreward = Qtable[gdnumber].dir[pastloc].reward[2]+foi*averagereward;
						}
						
						//adjusted right reward
						drgdnumberfeed = 3;
						drgdnumber = gdnumber+drgdnumbercalc ();
						
						pastlocdr = pastlocdrcalc ();
						
						if (onedgeofgrid () == true)
						{
							Rightreward = -100;
						}
						else
						{
							averagereward = deeperrewardstimer();
							Rightreward = Qtable[gdnumber].dir[pastloc].reward[3]+foi*averagereward;
						}
						
						// bias up over down, no need to bias left over right
						Upreward += 0.1;
						
						//choosing next reward
						if (Upreward >= Downreward)
						{
							firstcalc = Upreward;
						}
						else
						{
							firstcalc = Downreward;
						}
						
						if (Leftreward >= Rightreward)
						{
							secondcalc = Leftreward;
						}
						else
						{
							secondcalc = Rightreward;
						}
						
						if (firstcalc >= secondcalc)
						{
							if (firstcalc == Upreward)
							{
								inpt = InputType::Up;
							}
							else
							{
								inpt = InputType::Down;
							}
						}
						else
						{
							if (secondcalc == Leftreward)
							{
								inpt = InputType::Left;
							}
							else
							{
								inpt = InputType::Right;
							}
						}
					}

					log ("Downreward "+Downreward);
					log ("Upreward "+Upreward);
					log ("Leftreward "+Leftreward);
					log ("Rightreward "+Rightreward);
					log ("firstcalc "+firstcalc);
					log ("secondcalc "+secondcalc);
					//log ("input "+inpt);
					
					//log ("down as input "+Qtable[gdnumber].dir[pastloc].reward[0]);
					//log ("up as input "+Qtable[gdnumber].dir[pastloc].reward[1]);
					//log ("left as input "+Qtable[gdnumber].dir[pastloc].reward[2]);
					//log ("right as input "+Qtable[gdnumber].dir[pastloc].reward[3]);
					//log ("up reward for spawn grid "+Qtable[Spawngdnumber].dir[pastloc].reward[1]);
					//log ("right reward for spawn grid "+Qtable[Spawngdnumber].dir[pastloc].reward[3]);
				}
				lowspeed = 0;
			}
		}
		else
		{
			//log("probe 2");

			//wheel check
			int ongrass = 0;
			ongrass = wheelsongrass (simManager);

			timer = timer-0.01;
			if ((timer-0 < approx) || (ongrass == 1))
			{
				log ("spawngrid "+SpawnGrid.x+","+SpawnGrid.y);
				log("probe 2.1");
				log("inpt is " + inpt);
				
				//logrewards(gdnumber, pastloc, "giving bad rewards");
				int loc = pastloc;
				log ("inpt "+inpt+" gdnumber "+gdnumber+" loc "+loc);
				log ("curgrid.x,spawngrid.x,curgid.y,spawngrid.y "+curgrid.x+","+SpawnGrid.x+","+curgrid.y+","+SpawnGrid.y);
				
				if (curgrid.x==SpawnGrid.x && curgrid.y==SpawnGrid.y)
				{
					loc = spawnpastloc;
				}
				
				//giving bad reward
				if (inpt == InputType::Down)
				{
				 Qtable[gdnumber].dir[loc].reward[0] = -4;
				}
				else if (inpt == InputType::Up)
				{
				 Qtable[gdnumber].dir[loc].reward[1] = -4;
				 log ("up givin bad reward");
				}
				else if (inpt == InputType::Left)
				{
				 Qtable[gdnumber].dir[loc].reward[2] = -4;
				}
				else if (inpt == InputType::Right)
				{
				 Qtable[gdnumber].dir[loc].reward[3] = -4;
				}
				else
				{
					log ("no input found");
				}
				
				//logrewards (gdnumber, pastloc, "after bad rewards givin");
				
				//finding unexplored areas
				logrewards(Spawngdnumber,spawnpastloc, "unexplored SG");
				
				if (Qtable[Spawngdnumber].dir[spawnpastloc].reward[0] == 0 ||
				    Qtable[Spawngdnumber].dir[spawnpastloc].reward[1] == 0 ||
					Qtable[Spawngdnumber].dir[spawnpastloc].reward[2] == 0 ||
					Qtable[Spawngdnumber].dir[spawnpastloc].reward[3] == 0)
				{
					log("probe 2.2");
					if (Qtable[Spawngdnumber].dir[spawnpastloc].reward[0]==0)
					{
						inpt = InputType::Down;
					}
					else if (Qtable[Spawngdnumber].dir[spawnpastloc].reward[1]==0)
					{
						inpt = InputType::Up;
					}
					else if (Qtable[Spawngdnumber].dir[spawnpastloc].reward[2]==0)
					{
						inpt = InputType::Left;
					}
					else if (Qtable[Spawngdnumber].dir[spawnpastloc].reward[3]==0)
					{
						inpt = InputType::Right;
					}
				}
				else
				{
					log("probe 2.3");
					//adjusted down reward
					drgdnumber = Spawngdnumber+1;
					averagereward = deeperrewardstimer();
					Downreward = Qtable[Spawngdnumber].dir[spawnpastloc].reward[0];//+foi*averagereward;
					
					//adjusted up reward
					if (Spawngdnumber <= 1)
					{
					Upreward = -100;
					}
					else
					{
					drgdnumber = Spawngdnumber-1;
					averagereward = deeperrewardstimer();
					Upreward = Qtable[Spawngdnumber].dir[spawnpastloc].reward[1];//+foi*averagereward;
					}
					
					//adjusted left reward
					if (Spawngdnumber <= length)
					{
						Leftreward = -100;
					}
					else
					{
					drgdnumber = Spawngdnumber-length;
					averagereward = deeperrewardstimer();
					Leftreward = Qtable[Spawngdnumber].dir[spawnpastloc].reward[2];//+foi*averagereward;
					}
					
					//adjusted right reward
					drgdnumber = Spawngdnumber+length;
					averagereward = deeperrewardstimer();
					Rightreward = Qtable[Spawngdnumber].dir[spawnpastloc].reward[3];//+foi*averagereward;
					
					//log ("Downreward "+Downreward);
					//log ("Upreward "+Upreward);
					//log ("Leftreward "+Leftreward);
					//log ("Rightreward "+Rightreward);
					//log ("down as input "+Qtable[Spawngdnumber].dir[spawnpastloc].reward[0]);
					//log ("up as input "+Qtable[Spawngdnumber].dir[spawnpastloc].reward[1]);
					//log ("left as input "+Qtable[Spawngdnumber].dir[spawnpastloc].reward[2]);
					//log ("right as input "+Qtable[Spawngdnumber].dir[spawnpastloc].reward[3]);	
					
					//choosing next reward	
					// bias up over down, no need to bias left over right
					Upreward += 0.1;
					
					if (Upreward >= Downreward)
					{
						firstcalc = Upreward;
						log ("first=up");
					}
					else
					{
						firstcalc = Downreward;
						log ("first=down");
					}
					
					if (Leftreward >= Rightreward)
					{
						secondcalc = Leftreward;
					}
					else
					{
						secondcalc = Rightreward;
					}
					
					if (firstcalc >= secondcalc)
					{
						if (firstcalc == Upreward)
						{
							inpt = InputType::Up;
							log ("inpt=up");
						}
						else
						{
							inpt = InputType::Down;
							log ("inpt=down");
						}
					}
					else
					{
						if (secondcalc == Leftreward)
						{
							inpt = InputType::Left;
						}
						else
						{
							inpt = InputType::Right;
						}
					}
					
					log ("firstcalc "+firstcalc+" secondcalc "+secondcalc);
				}
			  
			timer = 5;
			noreward = 1;
			simManager.GiveUp();
			}
			//log("no movement");
		}
    }

	// count # of checkpoints taken
    TM::PlayerInfo@ PI = simManager.get_PlayerInfo();
    array<int> ckpt = PI.get_CheckpointStates();
	uint taken = 0;
	
    /*for(uint cur = 0;cur<numckpt;cur=cur+1)
    {
        if(ckpt[cur]==1)
        {
            taken = taken+1;
        }
    }
    log("number of checkpoints taken "+taken+" of "+numckpt);*/
	
	if (ckpt[numckpt-1] == 1)
	{
		simManager.Respawn();
	}
	
	if (PI.RaceFinished == true)
	{
		timer = 5;
	}
	
	//log ("timer "+timer);
	//log ("input "+inpt);
	//log ("racetime "+simManager.PlayerInfo.RaceTime);
	simManager.SetInputState(inpt, 1);
    oldgrid = curgrid;
	oldgdnumber = gdnumber;
	oldinpt = inpt;
}

void OnSimulationBegin(SimulationManager@ simManager)
{
}

void OnSimulationStep(SimulationManager@ simManager, bool userCancelled)
{
}

void OnSimulationEnd(SimulationManager@ simManager, SimulationResult result)
{
}

void OnCheckpointCountChanged(SimulationManager@ simManager, int count, int target)
{
}

void OnLapCountChanged(SimulationManager@ simManager, int count, int target)
{
}

void Render()
{
}

void Main()
{
    origin.x=0;
    origin.y=0;
    origin.z=0;

    upper.x=1024;
    upper.y=1024;
    upper.z=0;

    size.x=8;
    size.y=8;

	length = upper.x/size.x;

    oldgrid.x=0;
    oldgrid.y=0;

    numckpt=0;
	
	// these are for 32-unit grid
	finlocx=1;
	finlocy=3;
	
	// scale to other grid sizes
	finlocx *= (32/size.x);
	finlocy *= (32/size.y);
	
	oldgdnumber=0;
	
	foi = 1.5;
	
	InputType inpt = InputType::None;
	InputType oldinpt = InputType::None;
	
	timer = 5;
	approx = 0.01;
	
    @Qtable = array<Qcell>((upper.x*upper.y)/(size.x*size.y)+1);
	Arrayhaszero = 4;
	
    log("Plugin started.");
}

void OnDisabled()
{
}

PluginInfo@ GetPluginInfo()
{
    auto info = PluginInfo();
    info.Name = "Full Q-Table";
    info.Author = "Zander Emmerton";
    info.Version = "v1.6.0";
    info.Description = "Reinforced learning ML";
    return info;
}
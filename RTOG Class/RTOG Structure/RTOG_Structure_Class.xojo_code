#tag Class
Protected Class RTOG_Structure_Class
	#tag Method, Flags = &h0
		Function Make_Array_of_Points(sd() as RTOG_Structure_Slice, Res_X as Single, Res_Y as Single, Res_Z as Single,nx as integer, ny as integer, nz as integer) As Boolean
		  //--------------------------------------------------------
		  // Make arrays of structure points
		  //
		  //
		  //
		  // 
		  // 
		  //
		  // Andrew Alexander Jan 2011
		  //--------------------------------------------------------
		  Dim tt as Boolean
		  
		  if gPref.DVH_Calc=1 Then // Use the is within routine of a polygon to find voxels
		    Make_Array_of_Points_FromIsWithin
		    
		  elseif gPref.DVH_Calc=0 Then // Just use the XoJo graphics routine to find voxels within the contour
		    Make_Array_of_Points_FromImages
		    
		  elseif gPref.DVH_Calc=2 Then
		    tt= Make_Array_of_Points_FromImages_andIswithin(sd(), Res_X, Res_Y , Res_Z ,nx , ny,nz)
		  else
		    Return False
		  end
		  Return tt
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Make_Array_of_Points_FromImages()
		  //--------------------------------------------------------
		  // Make Polygon arrays of structure points for MAC
		  //
		  //
		  // Andrew Alexander Jan 2011
		  //--------------------------------------------------------
		  Dim v,a,k,j,pixy,pixx,bb, list(-1),rm_x(-1),rm_y(-1) ,x_pic,y_pic,i as Integer
		  Dim poly,poly_cm as Class_Polygon
		  Dim file as RTOG_Structure_Slice
		  Dim x,y,newarea as Single
		  Dim arepoints_b,findwithin,notrealpoint as Boolean
		  Dim p as Picture
		  Dim gg as Graphics
		  //Dim tmpsurf as RGBSurface
		  //--------------------------------------------------------
		  
		  
		  // Make Index of X,Y Pixel points
		  
		  for i = 0 to ubound(Structure_Data)
		    file = new RTOG_Structure_Slice
		    file = structure_Data(i)
		    
		    
		    arepoints_b=False
		    
		    
		    ReDim file.Axial_Points_X(-1)
		    ReDim file.Axial_Points_Y(-1)
		    
		    
		    
		    for j = 0 to ubound(file.Structure_Poly)
		      if file.Structure_Poly(j) <> Nil Then
		        
		        if j=0 Then
		          p=New Picture(gVis.nx,gVis.ny,32) //Changed to "New Picture" by William Davis on finding that "NewPicture" had been deprecated
		          gg = p.graphics
		          gg.foreColor =RGB(255,255,255) //White
		          gg.FillRect(0,0,gg.Width,gg.Height)
		          //gg.UseOldRenderer=True
		        end
		        
		        if UBound(file.Segments(j).Points)>0 Then
		          poly=file.Structure_Poly(j)
		          arepoints_b=True
		          
		          if poly.PointWithin_OtherPoly Then //Exclusion region
		            gg.foreColor =RGB(255,255,255) //White
		            gg.FillPolygon poly.Points
		            
		            gg.foreColor =RGB(200,0,0) //Border
		            gg.DrawPolygon poly.Points
		            
		          else // draw real contour and border
		            gg.foreColor =RGB(225,0,0) //FillColor
		            gg.FillPolygon poly.Points
		            
		            gg.foreColor =RGB(200,0,0) //Border
		            gg.DrawPolygon Poly.Points
		            
		          end
		        end
		        
		      end
		    next // End for one segment
		    
		    
		    
		    
		    if arepoints_b Then
		      for a=0 to gg.Width
		        for k=0 to gg.Height
		          v= p.RGBSurface.Pixel(a,k).Red
		          if v=200 or v=225 Then
		            file.Axial_Points_X.append a
		            file.Axial_Points_y.append k
		          end
		        Next
		      Next
		    end
		  Next
		  
		  
		  
		  Loaded_Points=True
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Make_Array_of_Points_FromImages_andIswithin(sd() as RTOG_Structure_Slice, Res_X as Single, Res_Y as Single, Res_Z as Single,nx as integer, ny as integer, nz as integer) As Boolean
		  //--------------------------------------------------------
		  // Make Polygon arrays of structure points for MAC
		  //
		  //
		  // Andrew Alexander Jan 2019
		  //--------------------------------------------------------
		  Dim v,a,k,j,pixy,pixx,bb, list(-1),rm_x(-1),rm_y(-1) ,x_pic,y_pic,i,x_low,x_high,y_low,y_high as Integer
		  Dim poly,poly_cm as Class_Polygon
		  Dim file as RTOG_Structure_Slice
		  Dim x,y,newarea as Single
		  Dim arepoints_b,findwithin,notrealpoint as Boolean
		  Dim p as Picture
		  Dim gg as Graphics
		  //--------------------------------------------------------
		  
		  
		  if nx=0 or ny=0 or UBound(sd)<0 Then
		    Return False
		  end
		  
		  
		  // Make Index of X,Y Pixel points
		  
		  for i = 0 to ubound(sd)
		    file = sd(i)
		    
		    x_low=nx
		    x_high=0
		    
		    y_low=ny
		    y_high=0
		    
		    
		    
		    arepoints_b=False
		    
		    if file=Nil Then
		      Return False
		    end
		    
		    ReDim file.Axial_Points_X(-1)
		    ReDim file.Axial_Points_Y(-1)
		    
		    
		    
		    for j = 0 to ubound(file.Structure_Poly)
		      if file.Structure_Poly(j) <> Nil Then
		        
		        if j=0 Then
		          p=New Picture(nx,ny,32) //Changed to "New Picture" by William Davis on finding that "NewPicture" had been deprecated
		          gg = p.graphics
		          gg.foreColor =RGB(255,255,255) //White
		          gg.FillRect(0,0,gg.Width,gg.Height)
		          //gg.UseOldRenderer=True
		        end
		        
		        if UBound(file.Segments(j).Points)>0 Then
		          poly=file.Structure_Poly(j)
		          arepoints_b=True
		          
		          if poly.PointWithin_OtherPoly Then
		            gg.foreColor =RGB(255,255,255) //White
		            gg.FillPolygon poly.Points
		            
		            gg.foreColor =RGB(200,0,0) //Boarder
		            gg.DrawPolygon poly.Points
		            
		          else // draw picture
		            gg.foreColor =RGB(225,0,0) //FillColor
		            gg.FillPolygon poly.Points
		            
		            gg.foreColor =RGB(200,0,0) //Boarder
		            gg.DrawPolygon Poly.Points
		            
		            if Poly.LeftEdge<x_low Then
		              x_low=Poly.LeftEdge
		            end
		            
		            if poly.RightEdge>x_high Then
		              x_high=Poly.RightEdge
		            end
		            
		            if Poly.TopEdge<y_low Then
		              y_low=Poly.TopEdge
		            end
		            
		            if poly.BottomEdge>y_high Then
		              y_high=Poly.BottomEdge
		            end
		            
		          end
		        end
		        
		      end
		    next // End for one segment
		    
		    
		    
		    
		    if arepoints_b Then
		      
		      for a=x_low to x_high
		        for k=y_low to y_high
		          v= p.RGBSurface.Pixel(a,k).Red
		          if v=200 Then
		            //Lookup boarder values
		            findwithin=False
		            notrealpoint=False
		            
		            for j = 0 to ubound(file.Structure_Poly)
		              poly=file.Structure_Poly(j)
		              if poly.PointWithin_OtherPoly=False Then
		                if Poly.IsWithin(a,k) Then
		                  findwithin=True
		                end
		              end
		              
		              if Poly.PointWithin_OtherPoly Then
		                if Poly.IsWithin(a,k) Then
		                  notrealpoint=True
		                end
		              end
		            next
		            
		            if findwithin and not notrealpoint Then
		              file.Axial_Points_X.append a
		              file.Axial_Points_y.append k
		            end
		            
		            
		          elseif v=225 Then// Value for pixels within contour
		            //
		            file.Axial_Points_X.append a
		            file.Axial_Points_y.append k
		          end
		        Next
		      Next
		    end
		  Next
		  
		  Return True
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Make_Array_of_Points_FromIsWithin()
		  //--------------------------------------------------------
		  // Make Polygon arrays of structure points for Windows
		  //
		  //
		  //
		  //
		  // Andrew Alexander Jan 2011
		  //--------------------------------------------------------
		  Dim a,k,j,pixy,pixx,bb, list(-1),rm_x(-1),rm_y(-1) ,x_pic,y_pic,i as Integer
		  Dim poly,poly_cm as Class_Polygon
		  Dim file as RTOG_Structure_Slice
		  Dim x,y,newarea as Single
		  Dim arepoints_b as Boolean
		  //--------------------------------------------------------
		  
		  
		  // Make Index of X,Y Pixel points
		  
		  for i = 0 to ubound(Structure_Data)
		    file = new RTOG_Structure_Slice
		    file = structure_Data(i)
		    
		    //p=NewPicture(gVis.nx,gVis.ny,32)
		    arepoints_b=False
		    ReDim rm_x(-1)
		    ReDim rm_y(-1)
		    
		    ReDim file.Axial_Points_X(-1)
		    ReDim file.Axial_Points_Y(-1)
		    
		    //gg = p.graphics
		    
		    for j = 0 to ubound(file.Structure_Poly)
		      if file.Structure_Poly(j) <> Nil Then
		        
		        poly=file.Structure_Poly(j)
		        if UBound(file.Segments(j).Points)>-1 Then
		          poly = new class_polygon
		          poly=file.Structure_Poly(j)
		          arepoints_b=True
		          
		          if poly.PointWithin_OtherPoly Then
		            //gg.foreColor =RGB(255,255,255) //White
		            //gg.FillPolygon poly.Points
		            
		            
		            //Make remove array
		            
		            for x_pic=Poly.LeftEdge to Poly.RightEdge
		              for y_pic=Poly.TopEdge to Poly.BottomEdge
		                if Poly.IsWithin(x_pic,y_pic) Then
		                  rm_x.Append x_pic
		                  rm_y.Append y_pic
		                end
		              Next
		            Next
		            
		            
		            
		          else // draw picture
		            //gg.foreColor =RGB(0,0,0) //Black
		            //gg.FillPolygon poly.Points
		            
		            for x_pic=Poly.LeftEdge to Poly.RightEdge
		              for y_pic=Poly.TopEdge to Poly.BottomEdge
		                if Poly.IsWithin(x_pic,y_pic) Then
		                  file.Axial_Points_X.Append x_pic
		                  file.Axial_Points_Y.Append y_pic
		                end
		              Next
		            Next
		          end
		          
		        end
		      end
		    next // End for one segment
		    
		    if arepoints_b Then
		      for j=0 to UBound(rm_x)
		        for a=UBound(file.Axial_Points_X) DownTo 0
		          if file.Axial_Points_X(a)=rm_x(j) and file.Axial_Points_Y(a)=rm_y(j) Then
		            file.Axial_Points_X.Remove a
		            file.Axial_Points_Y.Remove a
		            Exit for a
		          end
		        Next
		      Next
		    end
		  next
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Make_Polygon(sd() as RTOG_Structure_Slice, Res_X as Single, Res_Y as Single, Res_Z as Single) As Boolean
		  //--------------------------------------------------------
		  // Make Polygon arrays of structure points
		  //
		  //
		  //
		  // Calculate Structure Volume
		  // Arrange Largest Polygon per strucutre per segment -- Not finished
		  //
		  // Andrew Alexander Jan 2011
		  //--------------------------------------------------------
		  Dim a,k,j,pixy,pixx,bb, list(-1),rm_x(-1),rm_y(-1) ,x_pic,y_pic,i as Integer
		  Dim poly,poly_cm as Class_Polygon
		  Dim file as RTOG_Structure_Slice
		  Dim x,y,newarea as Single
		  Dim arepoints_b as Boolean
		  Dim x_cm,y_cm as Double
		  //--------------------------------------------------------
		  
		  
		  // make sure largest poly is at lowest index
		  
		  if UBound(sd)<0 Then
		    Return False
		  end
		  
		  for a=0 to UBound(sd)
		    file = sd(a)
		    if file=nil Then
		      Return false
		    end
		    if UBound(file.Segments)>0 Then
		      ReDim List(-1)
		      for j = 0 to ubound(file.segments)
		        list.Append UBound(file.Segments(j).Points)
		      next
		      //list.SortWith
		    end
		  Next
		  
		  Structure_Volume=0
		  
		  for a=0 to UBound(sd)
		    file = sd(a)
		    ReDim file.Structure_Poly(-1)
		    newarea=0
		    for j = 0 to ubound(file.segments)
		      if UBound(file.Segments(j).Points)>=0 then
		        poly=new Class_Polygon
		        poly_cm=new Class_Polygon
		        ReDim poly.Points(0)
		        for k =0 to ubound(file.segments(j).Points)
		          x_cm=file.segments(j).Points(k).x
		          y_cm=file.segments(j).Points(k).y
		          poly.AddPoint_D x_cm,y_cm
		          poly_cm.AddPoint_D x_cm, y_cm 
		          x=(x_cm-gRTOG.Structures.x_offset+Res_X/2)/Res_X
		          y=(y_cm- gRTOG.Structures.y_offset+Res_y/2)/Res_Y
		          pixx=Floor(x)
		          pixy=Floor(y)
		          poly.AddPoint pixx,pixy
		          
		          if pixx<0 or pixy<0 Then
		            Errors.append ("Error within Make Polygon, Pix value is less than 0")
		          end
		          
		          for bb=0 to UBound(file.Structure_Poly)
		            if poly.PointWithin_OtherPoly=False Then
		              if file.Structure_Poly(bb).IsWithin(pixx,pixy) Then
		                poly.PointWithin_OtherPoly=True
		                poly.PolyIsWithin_Index=bb
		              end
		            end
		          next
		        next
		        if Poly.PointWithin_OtherPoly Then // Sub area
		          newarea=newarea-poly_cm.Area_D
		        else // Independant area add
		          newarea=newarea+poly_cm.Area_D
		        end
		        file.Structure_Poly.Append Poly
		      end
		    Next
		    Structure_Volume=Structure_Volume+newarea*Res_Z
		  Next
		  
		  Return True
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		changed As boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		colour As string
	#tag EndProperty

	#tag Property, Flags = &h0
		DVH_Calculate As Boolean = false
	#tag EndProperty

	#tag Property, Flags = &h0
		ElectronDensity As Single
	#tag EndProperty

	#tag Property, Flags = &h0
		ElectronDensityOverride As Boolean = false
	#tag EndProperty

	#tag Property, Flags = &h0
		File_Num As integer
	#tag EndProperty

	#tag Property, Flags = &h0
		Loaded_Points As Boolean = false
	#tag EndProperty

	#tag Property, Flags = &h0
		Loaded_PointsHR As Boolean = false
	#tag EndProperty

	#tag Property, Flags = &h0
		Loaded_Poly As Boolean = false
	#tag EndProperty

	#tag Property, Flags = &h0
		Loaded_PolyHR As Boolean = false
	#tag EndProperty

	#tag Property, Flags = &h0
		Number_R As boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		Number_Rep As string
	#tag EndProperty

	#tag Property, Flags = &h0
		Num_of_Scans As integer
	#tag EndProperty

	#tag Property, Flags = &h0
		Num_S As boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		ROI_Number As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		scolor As color
	#tag EndProperty

	#tag Property, Flags = &h0
		StructureType As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Structure_Data(-1) As RTOG_Structure_Slice
	#tag EndProperty

	#tag Property, Flags = &h0
		Structure_DataHR(-1) As RTOG_Structure_Slice
	#tag EndProperty

	#tag Property, Flags = &h0
		Structure_F As boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		Structure_Format As string
	#tag EndProperty

	#tag Property, Flags = &h0
		Structure_N As boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		Structure_Name As string
	#tag EndProperty

	#tag Property, Flags = &h0
		Structure_Volume As Single
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="changed"
			Visible=false
			Group="Behavior"
			InitialValue="0"
			Type="boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="colour"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="string"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="DVH_Calculate"
			Visible=false
			Group="Behavior"
			InitialValue="false"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="ElectronDensity"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Single"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="ElectronDensityOverride"
			Visible=false
			Group="Behavior"
			InitialValue="false"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="File_Num"
			Visible=false
			Group="Behavior"
			InitialValue="0"
			Type="integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Loaded_Points"
			Visible=false
			Group="Behavior"
			InitialValue="false"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Loaded_PointsHR"
			Visible=false
			Group="Behavior"
			InitialValue="false"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Loaded_Poly"
			Visible=false
			Group="Behavior"
			InitialValue="false"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Loaded_PolyHR"
			Visible=false
			Group="Behavior"
			InitialValue="false"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Number_R"
			Visible=false
			Group="Behavior"
			InitialValue="0"
			Type="boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Number_Rep"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="string"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Num_of_Scans"
			Visible=false
			Group="Behavior"
			InitialValue="0"
			Type="integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Num_S"
			Visible=false
			Group="Behavior"
			InitialValue="0"
			Type="boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="ROI_Number"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="scolor"
			Visible=false
			Group="Behavior"
			InitialValue="&h000000"
			Type="color"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="StructureType"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Structure_F"
			Visible=false
			Group="Behavior"
			InitialValue="0"
			Type="boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Structure_Format"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="string"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Structure_N"
			Visible=false
			Group="Behavior"
			InitialValue="0"
			Type="boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Structure_Name"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="string"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Structure_Volume"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Single"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass

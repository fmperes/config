VimUnDoĺ ¸Ů	c.UřIę_ľ(GšQĘ$LvęÄ*˘^Čń7  ˛   A    if old_ctx.sim_ctx.new_slip_system && slip_coefficient != 0 {                            e_+    _Đ                            ˙˙˙˙                                                                                                                                                                                                                                                                                                                                                             e^l     ő              ą   package embergen_simulator       import "core:fmt"       !import prof "../../jui/jprofiler"           ldo_prepare_collision :: proc(old_ctx: ^Context, slip_coefficient, simulation_time: f32, should_init: bool) {   	sim_ctx := &old_ctx.sim_ctx;       	if should_init {   =		prof.SCOPED_OPENGL_BLOCK("Clear Workgroup Collision Mask");   +		texture_clear(old_ctx, .Workgroup_Mask_8)   ,		texture_clear(old_ctx, .Workgroup_Mask_16)   	}       	bbox_collision_mask := u32(0)   :	bbox_collision_mask |= u32(sim_ctx.blocking_floor)   << 0   :	bbox_collision_mask |= u32(sim_ctx.blocking_ceiling) << 1   :	bbox_collision_mask |= u32(sim_ctx.blocking_minus_x) << 2   :	bbox_collision_mask |= u32(sim_ctx.blocking_plus_x)  << 3   :	bbox_collision_mask |= u32(sim_ctx.blocking_minus_y) << 4   :	bbox_collision_mask |= u32(sim_ctx.blocking_plus_y)  << 5       	if should_init {   C		stack_depth := sim_ctx.uniforms_distance_ops_colliders_max_depth;   <		shader_program : Program_Type = .Workgroup_Collision_Mask;       Z		prof.SCOPED_OPENGL_BLOCK(fmt.tprintf("Mask Collider Workgroups Depth %d", stack_depth));       U		do_update_uniforms_colliders(old_ctx, shader_program, &sim_ctx.collision_uniforms);   z		update_ssbo(sim_ctx.ssbo_distance_fields_collider, sim_ctx.uniforms_distance_ops_colliders[:], .Collider_Distance_Data);   O		set_uniform_f32(old_ctx, shader_program, "time_in_seconds", simulation_time);   W		set_uniform_u32(old_ctx, shader_program, "bbox_collision_mask", bbox_collision_mask);   _		set_uniform_i32x3(old_ctx, shader_program, "size", to_i32(old_ctx.textures[.Velocity].size));       		bind_textures(ctx=old_ctx,    
			tex = {   "				{.Animation_SDF_Velocity0, 0},   "				{.Animation_SDF_Velocity1, 0},   "				{.Animation_SDF_Velocity2, 0},   "				{.Animation_SDF_Velocity3, 0},   				{.Animation_Mask0, 0},   				{.Animation_Mask1, 0},   				{.Animation_Mask2, 0},   				{.Animation_Mask3, 0},   			},   
			img = {   				{.Workgroup_Mask_8, 0},   				{.Workgroup_Mask_16, 0},   			},   		);       U		execute_compute(old_ctx, shader_program, old_ctx.textures[.Workgroup_Mask_8].size);   	}   	{   C		stack_depth := sim_ctx.uniforms_distance_ops_colliders_max_depth;   5		shader_program : Program_Type = .Prepare_Collision;       S		prof.SCOPED_OPENGL_BLOCK(fmt.tprintf("Prepare Collision Depth %d", stack_depth));   U		do_update_uniforms_colliders(old_ctx, shader_program, &sim_ctx.collision_uniforms);   z		update_ssbo(sim_ctx.ssbo_distance_fields_collider, sim_ctx.uniforms_distance_ops_colliders[:], .Collider_Distance_Data);   O		set_uniform_f32(old_ctx, shader_program, "time_in_seconds", simulation_time);   T		set_uniform_f32(old_ctx, shader_program, "reciprocal_timestep", sim_ctx.timestep);   W		set_uniform_u32(old_ctx, shader_program, "bbox_collision_mask", bbox_collision_mask);   a		set_uniform_i32x3(old_ctx, shader_program, "size", to_i32(old_ctx.textures[.Collision0].size));       W        set_uniform_f32(old_ctx, shader_program, "slip_coefficient", slip_coefficient);   f        set_uniform_bool(old_ctx, shader_program, "new_slip_system", old_ctx.sim_ctx.new_slip_system);   		   		bind_textures(ctx=old_ctx,    
			tex = {   "				{.Animation_SDF_Velocity0, 0},   "				{.Animation_SDF_Velocity1, 0},   "				{.Animation_SDF_Velocity2, 0},   "				{.Animation_SDF_Velocity3, 0},   				{.Animation_Mask0, 0},   				{.Animation_Mask1, 0},   				{.Animation_Mask2, 0},   				{.Animation_Mask3, 0},   				{.Workgroup_Mask_8, 0},                   {.Velocity, 0},   			},   
			img = {   				{.Velocity, 0},    				{.Collision0, 0},   			},   		);       O		execute_compute(old_ctx, shader_program, old_ctx.textures[.Collision0].size);   	}   }       0do_hourglass_filter :: proc(old_ctx: ^Context) {   .	prof.SCOPED_OPENGL_BLOCK("Hourglass Filter");       u	set_uniform_f32(old_ctx, .Hourglass_Filter, "hourglass_filter_strength", old_ctx.sim_ctx.hourglass_filter_strength);   a	set_uniform_i32x3(old_ctx, .Hourglass_Filter, "size", to_i32(old_ctx.textures[.Velocity].size));   w	bind_textures(ctx=old_ctx, tex = {{.Velocity, 0}, {.Collision0, 0}, {.Workgroup_Mask_16, 0}}, img = {{.Velocity, 1}});   S	execute_compute(old_ctx, .Hourglass_Filter, old_ctx.textures[.Velocity].size / 2);   *	rotate_texture_chain(old_ctx, .Velocity);   }       ^do_divergence :: proc(old_ctx: ^Context, is_pre_divergence: bool, initialize_pressure: bool) {   	sim_ctx := &old_ctx.sim_ctx;       (	prof.SCOPED_OPENGL_BLOCK("Divergence");   ]	set_uniform_i32x3(old_ctx, .Divergence, "size", to_i32(old_ctx.textures[.Divergence].size));   P	set_uniform_bool(old_ctx, .Divergence, "is_pre_divergence", is_pre_divergence);   T	set_uniform_bool(old_ctx, .Divergence, "initialize_pressure", initialize_pressure);       	bind_textures(ctx=old_ctx, tex = {{.Velocity, 0}, {.Extra_Divergence, 0}, {.Collision0, 0}}, img = {{.Divergence, 0}, {.Pressure, 0}});   O	execute_compute(old_ctx, .Divergence, old_ctx.textures[.Divergence].size / 2);   }       Jdo_multigrid_recipe :: proc(old_ctx: ^Context, recipe: []Multigrid_Node) {   	X0 :: Texture_Name.Pressure;   	B0 :: Texture_Name.Divergence;       '	prof.SCOPED_OPENGL_BLOCK("Multigrid");       	sim_ctx := &old_ctx.sim_ctx;       	for node, i in recipe {   		if i > 0 {   			previous_node := recipe[i-1]       (			if node.level > previous_node.level {   5				residual_program: Program_Type = .Residual_Corner   !				if previous_node.level == 0 {   2					residual_program = .Residual_Corner_Collision   				}        				switch previous_node.level {   				case 0:   X					do_projection_residual(old_ctx, residual_program,  X0,  B0, .Collision0,  X0, 1, 0)   9					do_projection_restrict(old_ctx,  X0, .B1, .X1, 1, 0)   				case 1:   X					do_projection_residual(old_ctx, residual_program, .X1, .B1, .Collision0, .X1, 1, 1)   9					do_projection_restrict(old_ctx, .X1, .B2, .X2, 1, 1)   				case 2:   X					do_projection_residual(old_ctx, residual_program, .X2, .B2, .Collision0, .X2, 1, 2)   9					do_projection_restrict(old_ctx, .X2, .B3, .X3, 1, 2)   				case 3:   X					do_projection_residual(old_ctx, residual_program, .X3, .B3, .Collision0, .X3, 1, 3)   9					do_projection_restrict(old_ctx, .X3, .B4, .X4, 1, 3)   				}   				   @				prof.BEGIN_OPENGL_BLOCK(fmt.tprintf("Level %d", node.level))   /			} else if node.level < previous_node.level {   G				prof.END_OPENGL_BLOCK(fmt.tprintf("Level %d", previous_node.level))    				switch previous_node.level {   :				case 1: do_projection_prolongate(old_ctx, .X1,  X0, 1)   :				case 2: do_projection_prolongate(old_ctx, .X2, .X1, 2)   :				case 3: do_projection_prolongate(old_ctx, .X3, .X2, 3)   :				case 4: do_projection_prolongate(old_ctx, .X4, .X3, 4)   				}   			}   		}       		program: Program_Type   		if node.type == .Vertex {   N			program = .Iterate_Vertex_Collision if node.level == 0 else .Iterate_Vertex   
		} else {   			if node.weight < 1.0 {   O				program = .Iterate_Corner_Collision if node.level == 0 else .Iterate_Corner   			} else {   W				program = .Iterate_Corner_Collision_SOR if node.level == 0 else .Iterate_Corner_SOR   			}   		}       		switch node.level {   n		case 0: do_projection_iterate(old_ctx, program,  X0,  B0, .Collision0, 0, node.iterations, f32(node.weight))   n		case 1: do_projection_iterate(old_ctx, program, .X1, .B1, .Collision0, 1, node.iterations, f32(node.weight))   n		case 2: do_projection_iterate(old_ctx, program, .X2, .B2, .Collision0, 2, node.iterations, f32(node.weight))   n		case 3: do_projection_iterate(old_ctx, program, .X3, .B3, .Collision0, 3, node.iterations, f32(node.weight))   n		case 4: do_projection_iterate(old_ctx, program, .X4, .B4, .Collision0, 4, node.iterations, f32(node.weight))   		}   	}   }       )do_multigrid :: proc(old_ctx: ^Context) {   	X0 :: Texture_Name.Pressure;   	B0 :: Texture_Name.Divergence;       	sim_ctx := &old_ctx.sim_ctx;   '	prof.SCOPED_OPENGL_BLOCK("Multigrid");       	max_coarsen := 0;   M	// We can coarsen as long as the coarser grid is a multiple on 8 on all axes   =	// and not smaller than 8, up to a maximum of 4 coarsenings.   	for i in 0..<4 {   -		s := sim_ctx.num_voxels / int(2 << uint(i))   		m := s % 8       +		if s.x < 8 || s.y < 8 || s.z < 8 do break   .		if m.x != 0 || m.y != 0 || m.z != 0 do break       		max_coarsen += 1;   	}   "	max_coarsen = min(4, max_coarsen)   	num_coarsen := max_coarsen       S	// We reduce the coarsening by one if there's not enough work on the coarsest grid   	for num_coarsen > 2 {   7		s := sim_ctx.num_voxels / int(1 << uint(num_coarsen))   		c := s.x * s.y * s.z   		if c < 131072 {   &			num_coarsen = max(2, num_coarsen-1)   
		} else {   			break   		}   	}       ,	for j in 0..<sim_ctx.multigrid_iterations {   7		prof.SCOPED_OPENGL_BLOCK(fmt.tprintf("Cycle %d", j));       		{   '			prof.SCOPED_OPENGL_BLOCK("Descent");   			if num_coarsen >= 1 {   -				prof.SCOPED_OPENGL_BLOCK("Level 0 -> 1");   				do_projection_iterate(old_ctx, .Iterate_Corner_Collision, X0, B0, .Collision0, 0, sim_ctx.pre_smooth_iterations + 0, 8.0/9.0)   ^				do_projection_residual(old_ctx, .Residual_Corner_Collision, X0, B0, .Collision0, X0, 1, 0)   7				do_projection_restrict(old_ctx, X0, .B1, .X1, 1, 0)   			}   			if num_coarsen >= 2 {   -				prof.SCOPED_OPENGL_BLOCK("Level 1 -> 2");   v				do_projection_iterate(old_ctx, .Iterate_Corner, .X1, .B1, .Invalid, 1, sim_ctx.pre_smooth_iterations + 1, 8.0/9.0)   T				do_projection_residual(old_ctx, .Residual_Corner, .X1, .B1, .Invalid, .X1, 1, 1)   8				do_projection_restrict(old_ctx, .X1, .B2, .X2, 1, 1)   			}   			if num_coarsen >= 3 {   -				prof.SCOPED_OPENGL_BLOCK("Level 2 -> 3");   v				do_projection_iterate(old_ctx, .Iterate_Corner, .X2, .B2, .Invalid, 2, sim_ctx.pre_smooth_iterations + 2, 8.0/9.0)   T				do_projection_residual(old_ctx, .Residual_Corner, .X2, .B2, .Invalid, .X2, 1, 2)   8				do_projection_restrict(old_ctx, .X2, .B3, .X3, 1, 2)   			}   			if num_coarsen >= 4 {   -				prof.SCOPED_OPENGL_BLOCK("Level 3 -> 4");   v				do_projection_iterate(old_ctx, .Iterate_Corner, .X3, .B3, .Invalid, 3, sim_ctx.pre_smooth_iterations + 3, 8.0/9.0)   T				do_projection_residual(old_ctx, .Residual_Corner, .X3, .B3, .Invalid, .X3, 1, 3)   8				do_projection_restrict(old_ctx, .X3, .B4, .X4, 1, 3)   			}   		}       		{   2			prof.SCOPED_OPENGL_BLOCK(fmt.tprintf("Solve"));   			if num_coarsen == 4 do do_projection_iterate(old_ctx, .Iterate_Corner,           .X4, .B4, .Invalid, 4, sim_ctx.solver_iterations, 8.0/9.0)   			if num_coarsen == 3 do do_projection_iterate(old_ctx, .Iterate_Corner,           .X3, .B3, .Invalid, 3, sim_ctx.solver_iterations, 8.0/9.0)   			if num_coarsen == 2 do do_projection_iterate(old_ctx, .Iterate_Corner,           .X2, .B2, .Invalid, 2, sim_ctx.solver_iterations, 8.0/9.0)   			if num_coarsen == 1 do do_projection_iterate(old_ctx, .Iterate_Corner,           .X1, .B1, .Invalid, 1, sim_ctx.solver_iterations, 8.0/9.0)   			if num_coarsen == 0 do do_projection_iterate(old_ctx, .Iterate_Corner_Collision,  X0,  B0, .Invalid, 0, sim_ctx.solver_iterations, 8.0/9.0)   		}       		{   3			prof.SCOPED_OPENGL_BLOCK(fmt.tprintf("Ascent"));   			if num_coarsen >= 4 {   -				prof.SCOPED_OPENGL_BLOCK("Level 4 -> 3");   2				do_projection_prolongate(old_ctx, .X4, .X3, 4)   w				do_projection_iterate(old_ctx, .Iterate_Corner, .X3, .B3, .Invalid, 3, sim_ctx.post_smooth_iterations + 6, 8.0/9.0)   			}   			if num_coarsen >= 3 {   -				prof.SCOPED_OPENGL_BLOCK("Level 3 -> 2");   2				do_projection_prolongate(old_ctx, .X3, .X2, 3)   w				do_projection_iterate(old_ctx, .Iterate_Corner, .X2, .B2, .Invalid, 2, sim_ctx.post_smooth_iterations + 4, 8.0/9.0)   			}   			if num_coarsen >= 2 {   -				prof.SCOPED_OPENGL_BLOCK("Level 2 -> 1");   2				do_projection_prolongate(old_ctx, .X2, .X1, 2)   w				do_projection_iterate(old_ctx, .Iterate_Corner, .X1, .B1, .Invalid, 1, sim_ctx.post_smooth_iterations + 2, 8.0/9.0)   			}   			if num_coarsen >= 1 {   -				prof.SCOPED_OPENGL_BLOCK("Level 1 -> 0");   1				do_projection_prolongate(old_ctx, .X1, X0, 1)   ~				do_projection_iterate(old_ctx, .Iterate_Corner_Collision, X0, B0, .Collision0, 0, sim_ctx.post_smooth_iterations, 8.0/9.0)   			}   		}       !		if sim_ctx.sor_iterations > 0 {   			do_projection_iterate(old_ctx, .Iterate_Corner_Collision_SOR, .Pressure, .Divergence, .Collision0, 0, sim_ctx.sor_iterations, old_ctx.sim_ctx.sor_omega)   		}       "		switch sim_ctx.correction_type {   Ś		case .Corner_No_Collision: do_projection_iterate(old_ctx, .Iterate_Corner,           .Pressure, .Divergence, .Collision0, 0, sim_ctx.correction_iterations, 8.0/9.0)   Ś		case .Corner_Collision:    do_projection_iterate(old_ctx, .Iterate_Corner_Collision, .Pressure, .Divergence, .Collision0, 0, sim_ctx.correction_iterations, 8.0/9.0)   Ś		case .Vertex_No_Collision: do_projection_iterate(old_ctx, .Iterate_Vertex,           .Pressure, .Divergence, .Collision0, 0, sim_ctx.correction_iterations, 8.0/9.0)   Ś		case .Vertex_Collision:    do_projection_iterate(old_ctx, .Iterate_Vertex_Collision, .Pressure, .Divergence, .Collision0, 0, sim_ctx.correction_iterations, 8.0/9.0)   		}   	}   }       ´do_projection_residual :: proc(old_ctx: ^Context, program: Program_Type, solution_tex, divergence_tex, collision_tex, residual_tex: Texture_Name, residual_slot: int, level: uint) {   F	prof.SCOPED_OPENGL_BLOCK(fmt.tprintf("%v Level %d", program, level));   	   4	size := to_i32(old_ctx.textures[residual_tex].size)   3	set_uniform_i32x3(old_ctx, program, "size", size);   	   U	if program == .Residual_Corner_Collision || program == .Residual_Corner do size /= 2       	bind_textures(ctx=old_ctx,    			tex = {   			{solution_tex, 0},    			{divergence_tex, 0},    			{collision_tex, 0},   			{.Workgroup_Mask_16, 0}   		},    			img = {   !			{solution_tex, residual_slot},   	});   1	execute_compute(old_ctx, program, to_u32(size));   }       Ądo_projection_restrict :: proc(old_ctx: ^Context, fine_residual_tex, coarse_divergence_tex, coarse_solution_tex: Texture_Name, residual_slot: int, level: uint) {   R	prof.SCOPED_OPENGL_BLOCK(fmt.tprintf("Restrict Level %d -> %d", level, level+1));       l	set_uniform_f32x3(old_ctx, .Restrict_2x2x2, "mul", 1.0 / to_f32(old_ctx.textures[fine_residual_tex].size));   Ä	set_uniform_f32(old_ctx, .Restrict_2x2x2, "scale", (6.0 / 3.0) * (1.0 / 6.0)); // NOTE: We overshoot the rhs term on purpose to over-compensate. Tests show it gives slightly improved convergence.   	bind_textures(ctx=old_ctx, tex = {{fine_residual_tex, residual_slot}}, img = {{coarse_divergence_tex, 0}, {coarse_solution_tex, 0}});   Y	execute_compute(old_ctx, .Restrict_2x2x2, old_ctx.textures[coarse_divergence_tex].size);   }       ido_projection_prolongate :: proc(old_ctx: ^Context, error_tex, solution_tex: Texture_Name, level: uint) {   T	prof.SCOPED_OPENGL_BLOCK(fmt.tprintf("Prolongate Level %d -> %d", level, level-1));   /	// Single-step prolongation + Error correction   4	size := to_i32(old_ctx.textures[solution_tex].size)   >	set_uniform_i32x3(old_ctx, .Prolongate_Single, "size", size);       
	size /= 2       b	bind_textures(ctx=old_ctx, tex = {{error_tex, 0}, {solution_tex, 0}}, img = {{solution_tex, 0}});   <	execute_compute(old_ctx, .Prolongate_Single, to_u32(size));   }       ´do_projection_iterate :: proc(old_ctx: ^Context, program: Program_Type, pressure_tex, divergence_tex, collision_tex: Texture_Name, level: uint, iteration_count: int, weight: f32) {   $	assert(program == .Iterate_Vertex \   +		|| program == .Iterate_Vertex_Collision \   !		|| program == .Iterate_Corner \   %		|| program == .Iterate_Corner_SOR \   +		|| program == .Iterate_Corner_Collision \   .		|| program == .Iterate_Corner_Collision_SOR)       \	prof.SCOPED_OPENGL_BLOCK(fmt.tprintf("%v Level %d x%d ", program, level, iteration_count));       4	set_uniform_f32(old_ctx, program, "omega", weight);       4	size := to_i32(old_ctx.textures[pressure_tex].size)   3	set_uniform_i32x3(old_ctx, program, "size", size);   
	size /= 2       	for _ in 0..<iteration_count {   		bind_textures(ctx=old_ctx,    
			tex = {   				{pressure_tex, 0},    				{divergence_tex, 0},    				{collision_tex, 0},   				{.Workgroup_Mask_16, 0}   			},    			img = {{pressure_tex, 1}   		});   2		execute_compute(old_ctx, program, to_u32(size));   .		rotate_texture_chain(old_ctx, pressure_tex);   	}   }       >do_gradient :: proc(old_ctx: ^Context, simulation_time: f32) {   &	prof.SCOPED_OPENGL_BLOCK("Gradient");       	sim_ctx := &old_ctx.sim_ctx;       +	shader_program : Program_Type = .Gradient;       ^	set_uniform_i32x3(old_ctx, shader_program, "size", to_i32(old_ctx.textures[.Velocity].size));       	bind_textures(   		ctx=old_ctx,   			tex = {   			{.Velocity, 0},   			{.Pressure, 0},   			{.Collision0, 0},   			{.Workgroup_Mask_8, 0},   		},   			img = {   			{.Velocity, 0},   		},   	);   P	execute_compute(old_ctx, shader_program, old_ctx.textures[.Velocity].size / 2);   }       ;do_slip :: proc(old_ctx: ^Context, slip_coefficient: f32) {   (    if old_ctx.sim_ctx.new_slip_system {   9        prof.SCOPED_OPENGL_BLOCK("Post-Projection Slip");   $        sim_ctx := &old_ctx.sim_ctx;       .        shader_program : Program_Type = .Slip;       [        do_update_uniforms_colliders(old_ctx, shader_program, &sim_ctx.collision_uniforms);           update_ssbo(sim_ctx.ssbo_distance_fields_collider, sim_ctx.uniforms_distance_ops_colliders[:], .Collider_Distance_Data);       %        bbox_collision_mask := u32(0)   A        bbox_collision_mask |= u32(sim_ctx.blocking_floor)   << 0   A        bbox_collision_mask |= u32(sim_ctx.blocking_ceiling) << 1   A        bbox_collision_mask |= u32(sim_ctx.blocking_minus_x) << 2   A        bbox_collision_mask |= u32(sim_ctx.blocking_plus_x)  << 3   A        bbox_collision_mask |= u32(sim_ctx.blocking_minus_y) << 4   A        bbox_collision_mask |= u32(sim_ctx.blocking_plus_y)  << 5   W		set_uniform_u32(old_ctx, shader_program, "bbox_collision_mask", bbox_collision_mask);   _		set_uniform_i32x3(old_ctx, shader_program, "size", to_i32(old_ctx.textures[.Velocity].size));       W        set_uniform_f32(old_ctx, shader_program, "slip_coefficient", slip_coefficient);   Z        set_uniform_f32(old_ctx, shader_program, "reciprocal_timestep", sim_ctx.timestep);               bind_textures(               ctx=old_ctx,               tex = {   .                {.Animation_SDF_Velocity0, 0},   .                {.Animation_SDF_Velocity1, 0},   .                {.Animation_SDF_Velocity2, 0},   .                {.Animation_SDF_Velocity3, 0},   &                {.Animation_Mask0, 0},   &                {.Animation_Mask1, 0},   &                {.Animation_Mask2, 0},   &                {.Animation_Mask3, 0},                   {.Velocity, 0},   !                {.Collision0, 0},   (                {.Workgroup_Mask_16, 0},               },               img = {                   {.Velocity, 0},               },   
        );   W        execute_compute(old_ctx, shader_program, old_ctx.textures[.Velocity].size / 2);       }   }55_Đ                          ˙˙˙˙                                                                                                                                                                                                                                                                                                                                                             e^n     ő      ˛          ő      ą    5ő                         :>                     ő                         :>                     ő      	                 C>                    ő                       J>                    5_Đ                          ˙˙˙˙                                                                                                                                                                                                                                                                                                                                                             e^t    ő      ˛          //NOTE(FP): T5ő                        K>                     ő                       K>                    ő      &                 `>                    ő      7              -   q>             -       ő      c                 >                    ő      h                 ˘>                    ő      l                 Ś>                     ő                     
   Ť>              
       ő                       ˛>                    ő                         §>                     ő      l                  Ś>                     ő      b       
          >      
              ő      b                 >                    ő      w                 ą>                     ő                        ś>                     ő                    )   š>             )       ő      ,                 Ţ>                    ő      )                 Ű>                    5_Đ                   E   3    ˙˙˙˙                                                                                                                                                                                                                                                                                                                                                             e_!    ő   D   E          f        set_uniform_bool(old_ctx, shader_program, "new_slip_system", old_ctx.sim_ctx.new_slip_system);5ő    D                            g               5_Đ                          ˙˙˙˙                                                                                                                                                                                                                                                                                                                                                             e_(     ő      ˛      A    if old_ctx.sim_ctx.new_slip_system && slip_coefficient != 0 {5ő                        >                     5_Đ      	                    ˙˙˙˙                                                                                                                                                                                                                                                                                                                                                             e_(     ő      ˛      :    if .sim_ctx.new_slip_system && slip_coefficient != 0 {5ő                        >                     5_Đ      
           	         ˙˙˙˙                                                                                                                                                                                                                                                                                                                                                             e_)     ő      ˛      9    if sim_ctx.new_slip_system && slip_coefficient != 0 {5ő                        >                     5_Đ   	              
         ˙˙˙˙                                                                                                                                                                                                                                                                                                                                                             e_)     ő      ˛      2    if .new_slip_system && slip_coefficient != 0 {5ő                        >                     5_Đ   
                       ˙˙˙˙                                                                                                                                                                                                                                                                                                                                                             e_)     ő      ˛      1    if new_slip_system && slip_coefficient != 0 {5ő                        >                     5_Đ                           ˙˙˙˙                                                                                                                                                                                                                                                                                                                                                             e_*    ő      ˛      !    if && slip_coefficient != 0 {5ő                        >                     5_Đ                         ˙˙˙˙                                                                                                                                                                                                                                                                                                                                                             e^Ď     ő      ł      :    if .sim_ctx.new_slip_system && slip_coefficient != 0 {5ő                        é>                     5_Đ                           ˙˙˙˙                                                                                                                                                                                                                                                                                                                                                             e^Đ     ő      ł      9    if sim_ctx.new_slip_system && slip_coefficient != 0 {5ő                        é>                     5çŞ